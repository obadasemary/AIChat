//
//  NetworkServiceProtocol.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Protocol defining the network service interface
protocol NetworkServiceProtocol: Sendable {
    /// The base URL for all requests
    var baseURL: URL? { get }

    /// Executes a network request and returns the raw response
    /// - Parameter request: The network request to execute
    /// - Returns: The network response
    func execute(_ request: NetworkRequest) async throws -> NetworkResponse

    /// Executes a network request and decodes the response
    /// - Parameters:
    ///   - request: The network request to execute
    ///   - type: The type to decode the response to
    ///   - decoder: The JSON decoder to use
    /// - Returns: The decoded response
    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType type: T.Type,
        decoder: JSONDecoder
    ) async throws -> T
}

// MARK: - Default implementations

extension NetworkServiceProtocol {
    /// Default implementation for decoding responses
    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let response = try await execute(request)
        return try response.decode(type, decoder: decoder)
    }
}
