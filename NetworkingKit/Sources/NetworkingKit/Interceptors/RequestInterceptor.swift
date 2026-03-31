import Foundation

/// Protocol for intercepting and modifying outgoing requests
public protocol RequestInterceptor: Sendable {
    /// Intercepts and potentially modifies a URL request before it is sent
    /// - Parameter request: The original URL request
    /// - Returns: The modified URL request
    func intercept(_ request: URLRequest) async throws -> URLRequest
}

/// Protocol for intercepting and modifying incoming responses
public protocol ResponseInterceptor: Sendable {
    /// Intercepts and potentially modifies a network response after it is received
    func intercept(_ response: NetworkResponse) async throws -> NetworkResponse
}
