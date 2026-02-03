//
//  NetworkManager.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Protocol defining the network manager interface
@MainActor
protocol NetworkManagerProtocol: Sendable {
    /// Executes a network request and returns the raw response
    func execute(_ request: NetworkRequest) async throws -> NetworkResponse

    /// Executes a network request and decodes the response to the specified type
    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder
    ) async throws -> T

    /// Executes a network request with retry logic
    func executeWithRetry(
        _ request: NetworkRequest,
        maxRetries: Int
    ) async throws -> NetworkResponse

    /// Executes a network request with retry logic and decodes the response
    func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder,
        maxRetries: Int
    ) async throws -> T
}

// MARK: - Default parameter values

extension NetworkManagerProtocol {
    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        try await execute(request, responseType: responseType, decoder: JSONDecoder())
    }

    func executeWithRetry(
        _ request: NetworkRequest
    ) async throws -> NetworkResponse {
        try await executeWithRetry(request, maxRetries: 3)
    }

    func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        try await executeWithRetry(request, responseType: responseType, decoder: JSONDecoder(), maxRetries: 3)
    }

    func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        maxRetries: Int
    ) async throws -> T {
        try await executeWithRetry(request, responseType: responseType, decoder: JSONDecoder(), maxRetries: maxRetries)
    }
}

/// Manager for network operations
@MainActor
@Observable
final class NetworkManager: Sendable {
    private let service: NetworkServiceProtocol
    private let retryHandler: RetryHandler
    private let logManager: LogManagerProtocol?

    /// Creates a new network manager
    /// - Parameters:
    ///   - service: The network service to use
    ///   - retryConfiguration: Configuration for retry behavior
    ///   - logManager: Optional log manager for analytics
    init(
        service: NetworkServiceProtocol,
        retryConfiguration: RetryConfiguration = .default,
        logManager: LogManagerProtocol? = nil
    ) {
        self.service = service
        self.retryHandler = RetryHandler(configuration: retryConfiguration)
        self.logManager = logManager
    }
}

// MARK: - NetworkManagerProtocol

extension NetworkManager: NetworkManagerProtocol {
    func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        logManager?.trackEvent(event: Event.requestStart(path: request.path, method: request.method.rawValue))

        do {
            let response = try await service.execute(request)
            logManager?.trackEvent(event: Event.requestSuccess(
                path: request.path,
                statusCode: response.statusCode
            ))
            return response
        } catch let error as NetworkError {
            logManager?.trackEvent(event: Event.requestFailed(
                path: request.path,
                error: error.localizedDescription
            ))
            throw error
        } catch {
            logManager?.trackEvent(event: Event.requestFailed(
                path: request.path,
                error: error.localizedDescription
            ))
            throw NetworkError.unknown(error.localizedDescription)
        }
    }

    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder
    ) async throws -> T {
        let response = try await execute(request)
        return try response.decode(responseType, decoder: decoder)
    }

    func executeWithRetry(
        _ request: NetworkRequest,
        maxRetries: Int
    ) async throws -> NetworkResponse {
        try await retryHandler.execute(maxRetries: maxRetries) {
            try await service.execute(request)
        }
    }

    func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder,
        maxRetries: Int
    ) async throws -> T {
        let response = try await executeWithRetry(request, maxRetries: maxRetries)
        return try response.decode(responseType, decoder: decoder)
    }
}

// MARK: - Analytics Events

private extension NetworkManager {
    enum Event: LoggableEvent {
        case requestStart(path: String, method: String)
        case requestSuccess(path: String, statusCode: Int)
        case requestFailed(path: String, error: String)

        var eventName: String {
            switch self {
            case .requestStart:
                return "network_request_start"
            case .requestSuccess:
                return "network_request_success"
            case .requestFailed:
                return "network_request_failed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .requestStart(let path, let method):
                return ["path": path, "method": method]
            case .requestSuccess(let path, let statusCode):
                return ["path": path, "status_code": statusCode]
            case .requestFailed(let path, let error):
                return ["path": path, "error": error]
            }
        }

        var type: LogType {
            switch self {
            case .requestStart, .requestSuccess:
                return .analytic
            case .requestFailed:
                return .severe
            }
        }
    }
}
