//
//  RequestInterceptor.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Protocol for intercepting and modifying outgoing requests
protocol RequestInterceptor: Sendable {
    /// Intercepts and potentially modifies a URL request before it is sent
    /// - Parameter request: The original URL request
    /// - Returns: The modified URL request
    func intercept(_ request: URLRequest) async throws -> URLRequest
}

/// Protocol for intercepting and modifying incoming responses
protocol ResponseInterceptor: Sendable {
    /// Intercepts and potentially modifies a network response after it is received
    /// - Parameter response: The original network response
    /// - Returns: The modified network response
    func intercept(_ response: NetworkResponse) async throws -> NetworkResponse
}
