// Interceptors.swift
// NetworkKit

import Foundation

/// Modifies an outgoing `URLRequest` before it is sent.
///
/// Interceptors are used for cross-cutting concerns such as adding auth headers
/// or logging. Multiple interceptors are applied in the order they are registered.
///
/// Conforming types **must** be `Sendable` so they can safely be captured
/// across concurrency domains.
public protocol RequestInterceptor: Sendable {
    /// Called with the request about to be sent.
    ///
    /// - Parameter request: The original `URLRequest`.
    /// - Returns: The (potentially modified) `URLRequest` to use.
    func intercept(_ request: URLRequest) async throws -> URLRequest
}

/// Modifies an incoming `NetworkResponse` after it is received.
///
/// Conforming types **must** be `Sendable` so they can safely be captured
/// across concurrency domains.
public protocol ResponseInterceptor: Sendable {
    /// Called with the response returned by the server.
    ///
    /// - Parameter response: The original `NetworkResponse`.
    /// - Returns: The (potentially modified) `NetworkResponse` to use.
    func intercept(_ response: NetworkResponse) async throws -> NetworkResponse
}
