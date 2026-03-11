// AuthInterceptor.swift
// NetworkKit

import Foundation

/// A `RequestInterceptor` that injects authentication credentials into every request.
///
/// `AuthInterceptor` is a value type (`struct`) with all immutable stored properties,
/// so it is automatically `Sendable` — no `@unchecked Sendable` required.
///
/// ## Usage
/// ```swift
/// // Bearer token
/// let auth = AuthInterceptor.bearer { try await tokenStore.currentToken() }
///
/// // Static API key
/// let auth = AuthInterceptor.apiKey(headerName: "X-Api-Key", apiKey: myKey)
/// ```
public struct AuthInterceptor: RequestInterceptor {

    // MARK: - Stored properties

    private let headerName: String
    /// Async closure that resolves the current credential.
    /// Returns `nil` to skip adding the header (e.g. when the user is signed out).
    private let tokenProvider: @Sendable () async throws -> String?

    // MARK: - Initialisers

    public init(
        headerName: String = "Authorization",
        tokenProvider: @escaping @Sendable () async throws -> String?
    ) {
        self.headerName = headerName
        self.tokenProvider = tokenProvider
    }

    // MARK: - Convenience factories

    /// Returns an interceptor that injects a `Bearer <token>` value.
    public static func bearer(
        tokenProvider: @escaping @Sendable () async throws -> String?
    ) -> AuthInterceptor {
        AuthInterceptor(headerName: "Authorization") {
            guard let token = try await tokenProvider() else { return nil }
            return "Bearer \(token)"
        }
    }

    /// Returns an interceptor that injects a static API key.
    public static func apiKey(headerName: String, apiKey: String) -> AuthInterceptor {
        AuthInterceptor(headerName: headerName) { apiKey }
    }

    // MARK: - RequestInterceptor

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard let token = try await tokenProvider() else { return request }
        var modified = request
        modified.setValue(token, forHTTPHeaderField: headerName)
        return modified
    }
}
