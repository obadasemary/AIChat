//
//  AuthInterceptor.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Request interceptor that adds authentication headers
final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    /// The authentication header name
    private let headerName: String

    /// Provider for the authentication token
    private let tokenProvider: @Sendable () async throws -> String?

    /// Creates a new auth interceptor
    /// - Parameters:
    ///   - headerName: The header name for the auth token (default: "Authorization")
    ///   - tokenProvider: A closure that provides the current auth token
    init(
        headerName: String = "Authorization",
        tokenProvider: @escaping @Sendable () async throws -> String?
    ) {
        self.headerName = headerName
        self.tokenProvider = tokenProvider
    }

    /// Creates a Bearer token auth interceptor
    /// - Parameter tokenProvider: A closure that provides the current auth token
    /// - Returns: An AuthInterceptor configured for Bearer token authentication
    static func bearer(
        tokenProvider: @escaping @Sendable () async throws -> String?
    ) -> AuthInterceptor {
        AuthInterceptor(headerName: "Authorization") {
            guard let token = try await tokenProvider() else {
                return nil
            }
            return "Bearer \(token)"
        }
    }

    /// Creates an API key auth interceptor
    /// - Parameters:
    ///   - headerName: The header name for the API key
    ///   - apiKey: The API key value
    /// - Returns: An AuthInterceptor configured for API key authentication
    static func apiKey(
        headerName: String,
        apiKey: String
    ) -> AuthInterceptor {
        AuthInterceptor(headerName: headerName) {
            apiKey
        }
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard let token = try await tokenProvider() else {
            return request
        }

        var modifiedRequest = request
        modifiedRequest.setValue(token, forHTTPHeaderField: headerName)
        return modifiedRequest
    }
}
