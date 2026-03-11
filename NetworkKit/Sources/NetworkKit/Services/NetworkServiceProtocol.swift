// NetworkServiceProtocol.swift
// NetworkKit

import Foundation

/// Low-level transport abstraction used by `NetworkClient`.
///
/// Concrete implementations (e.g. `URLSessionNetworkService`) handle the actual
/// I/O; mock implementations (e.g. `MockNetworkService`) replace the transport
/// layer during tests — no real network calls required.
///
/// All conforming types **must** be `Sendable` so they can be stored and called
/// across actor and task boundaries.
public protocol NetworkServiceProtocol: Sendable {

    /// The base URL prepended to relative paths in `NetworkRequest`.
    ///
    /// Set this on the concrete service when you want all requests to share a
    /// common host + path prefix (e.g. `https://api.example.com/v1`).
    var baseURL: URL? { get }

    /// Executes the request and returns the raw server response.
    ///
    /// - Throws: `NetworkError` on any transport or HTTP-layer failure.
    func execute(_ request: NetworkRequest) async throws -> NetworkResponse
}
