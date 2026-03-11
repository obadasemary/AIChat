// NetworkClient.swift
// NetworkKit

import Foundation

// MARK: - NetworkLogEvent

/// Events emitted by `NetworkClient` during a request lifecycle.
///
/// Consumers inject a `@Sendable` closure at initialisation time to receive
/// these events and forward them to their own analytics / logging infrastructure
/// — keeping `NetworkKit` free of any app-specific logging dependencies.
public enum NetworkLogEvent: Sendable {
    case requestStarted(path: String, method: String)
    case requestSucceeded(path: String, statusCode: Int)
    case requestFailed(path: String, error: String)
}

// MARK: - NetworkClient

/// High-level networking client.
///
/// ### Swift Concurrency design
/// `NetworkClient` is a `final class` whose stored properties are all `let`
/// and `Sendable`; the Swift 6 compiler can therefore verify it is `Sendable`
/// without `@unchecked`.
///
/// There is **no `@MainActor` annotation** — network I/O should not run on the
/// main thread.  Callers that need to push results to the UI hop to
/// `@MainActor` themselves.
///
/// There is **no `@Observable`** — that concern belongs to the app layer, not
/// the networking layer.  A ViewModel can wrap `NetworkClient` and expose
/// `@Published` or `@Observable` state as needed.
///
/// ## Usage
/// ```swift
/// let client = NetworkClient(
///     service: URLSessionNetworkService(baseURL: URL(string: "https://api.example.com")!),
///     logger: { event in analyticsManager.log(event) }
/// )
///
/// let user: User = try await client.execute(.get("/users/me"), responseType: User.self)
/// ```
public final class NetworkClient: NetworkClientProtocol, Sendable {

    // MARK: - Stored properties

    private let service: any NetworkServiceProtocol
    private let retryHandler: RetryHandler
    /// Optional observer for request lifecycle events.
    private let logger: (@Sendable (NetworkLogEvent) -> Void)?

    // MARK: - Initialiser

    public init(
        service: any NetworkServiceProtocol,
        retryConfiguration: RetryConfiguration = .default,
        logger: (@Sendable (NetworkLogEvent) -> Void)? = nil
    ) {
        self.service = service
        self.retryHandler = RetryHandler(configuration: retryConfiguration)
        self.logger = logger
    }

    // MARK: - NetworkClientProtocol

    public func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        logger?(.requestStarted(path: request.path, method: request.method.rawValue))

        do {
            let response = try await service.execute(request)
            logger?(.requestSucceeded(path: request.path, statusCode: response.statusCode))
            return response
        } catch let error as NetworkError {
            logger?(.requestFailed(path: request.path, error: error.localizedDescription))
            throw error
        } catch {
            let wrapped = NetworkError.unknown(error.localizedDescription)
            logger?(.requestFailed(path: request.path, error: wrapped.localizedDescription))
            throw wrapped
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
            try await self.service.execute(request)
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
