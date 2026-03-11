// NetworkClientProtocol.swift
// NetworkKit

import Foundation

/// The public contract for the high-level networking client.
///
/// ### Why no `@MainActor`?
/// Network I/O must run off the main thread.  Marking the protocol (or its
/// concrete implementation) `@MainActor` would force every request through
/// the main dispatch queue, blocking the UI and adding unnecessary context
/// switches.  Callers that need to update the UI after a request should hop
/// to `@MainActor` themselves (e.g. `await MainActor.run { … }`).
///
/// ### Sendable
/// Conforming types must be `Sendable` so the client can be stored as a
/// dependency and safely shared across actor and task boundaries.
public protocol NetworkClientProtocol: Sendable {

    /// Executes a request and returns the raw `NetworkResponse`.
    func execute(_ request: NetworkRequest) async throws -> NetworkResponse

    /// Executes a request and decodes the body using `decoder`.
    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder
    ) async throws -> T

    /// Executes a request with automatic retry on transient failures.
    func executeWithRetry(
        _ request: NetworkRequest,
        maxRetries: Int
    ) async throws -> NetworkResponse

    /// Executes a request with automatic retry and decodes the body using `decoder`.
    func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        decoder: JSONDecoder,
        maxRetries: Int
    ) async throws -> T
}

// MARK: - Default parameters

extension NetworkClientProtocol {

    /// Executes a request and decodes the body using a default `JSONDecoder`.
    public func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        try await execute(request, responseType: responseType, decoder: JSONDecoder())
    }

    /// Executes a request with up to 3 retries.
    public func executeWithRetry(_ request: NetworkRequest) async throws -> NetworkResponse {
        try await executeWithRetry(request, maxRetries: 3)
    }

    /// Executes a request with up to 3 retries and decodes using a default `JSONDecoder`.
    public func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        try await executeWithRetry(request, responseType: responseType, decoder: JSONDecoder(), maxRetries: 3)
    }

    /// Executes a request with a custom retry count and decodes using a default `JSONDecoder`.
    public func executeWithRetry<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type,
        maxRetries: Int
    ) async throws -> T {
        try await executeWithRetry(
            request,
            responseType: responseType,
            decoder: JSONDecoder(),
            maxRetries: maxRetries
        )
    }
}
