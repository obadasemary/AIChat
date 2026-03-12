import Foundation

/// A network event emitted by NetworkManager for observability
public struct NetworkEvent: Sendable {
    public enum EventType: String, Sendable {
        case requestStart = "network_request_start"
        case requestSuccess = "network_request_success"
        case requestFailed = "network_request_failed"
    }

    public let type: EventType
    public let parameters: [String: any Sendable]

    public init(type: EventType, parameters: [String: any Sendable]) {
        self.type = type
        self.parameters = parameters
    }
}

/// Protocol defining the network manager interface
@MainActor
public protocol NetworkManagerProtocol: Sendable {
    func execute(_ request: NetworkRequest) async throws -> NetworkResponse

    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder
    ) async throws -> T

    func executeWithRetry(
        _ request: NetworkRequest,
        maxRetries: Int
    ) async throws -> NetworkResponse

    func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder,
        maxRetries: Int
    ) async throws -> T
}

// MARK: - Default parameter values

extension NetworkManagerProtocol {
    public func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        try await execute(request, responseType: responseType, decoder: JSONDecoder())
    }

    public func executeWithRetry(
        _ request: NetworkRequest
    ) async throws -> NetworkResponse {
        try await executeWithRetry(request, maxRetries: 3)
    }

    public func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        try await executeWithRetry(request, responseType: responseType, decoder: JSONDecoder(), maxRetries: 3)
    }

    public func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        maxRetries: Int
    ) async throws -> T {
        try await executeWithRetry(request, responseType: responseType, decoder: JSONDecoder(), maxRetries: maxRetries)
    }
}

/// Manager for network operations
@MainActor
public final class NetworkManager: Sendable {
    private let service: NetworkServiceProtocol
    private let retryHandler: RetryHandler
    /// Optional event handler for observability — bridge to your app's logging system
    private let eventHandler: (@Sendable (NetworkEvent) -> Void)?

    public init(
        service: NetworkServiceProtocol,
        retryConfiguration: RetryConfiguration = .default,
        eventHandler: (@Sendable (NetworkEvent) -> Void)? = nil
    ) {
        self.service = service
        self.retryHandler = RetryHandler(configuration: retryConfiguration)
        self.eventHandler = eventHandler
    }
}

// MARK: - NetworkManagerProtocol

extension NetworkManager: NetworkManagerProtocol {
    public func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        eventHandler?(NetworkEvent(
            type: .requestStart,
            parameters: ["path": request.path, "method": request.method.rawValue]
        ))

        do {
            let response = try await service.execute(request)
            eventHandler?(NetworkEvent(
                type: .requestSuccess,
                parameters: ["path": request.path, "status_code": response.statusCode]
            ))
            return response
        } catch let error as NetworkError {
            eventHandler?(NetworkEvent(
                type: .requestFailed,
                parameters: ["path": request.path, "error": error.localizedDescription]
            ))
            throw error
        } catch {
            eventHandler?(NetworkEvent(
                type: .requestFailed,
                parameters: ["path": request.path, "error": error.localizedDescription]
            ))
            throw NetworkError.unknown(error.localizedDescription)
        }
    }

    public func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder
    ) async throws -> T {
        let response = try await execute(request)
        return try response.decode(responseType, decoder: decoder)
    }

    public func executeWithRetry(
        _ request: NetworkRequest,
        maxRetries: Int
    ) async throws -> NetworkResponse {
        try await retryHandler.execute(maxRetries: maxRetries) {
            try await self.execute(request)
        }
    }

    public func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder,
        maxRetries: Int
    ) async throws -> T {
        let response = try await executeWithRetry(request, maxRetries: maxRetries)
        return try response.decode(responseType, decoder: decoder)
    }
}
