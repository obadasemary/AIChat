import Foundation

/// Request interceptor that adds authentication headers
public final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    private let headerName: String
    private let tokenProvider: @Sendable () async throws -> String?

    /// Creates a new auth interceptor
    public init(
        headerName: String = "Authorization",
        tokenProvider: @escaping @Sendable () async throws -> String?
    ) {
        self.headerName = headerName
        self.tokenProvider = tokenProvider
    }

    /// Creates a Bearer token auth interceptor
    public static func bearer(
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
    public static func apiKey(
        headerName: String,
        apiKey: String
    ) -> AuthInterceptor {
        AuthInterceptor(headerName: headerName) {
            apiKey
        }
    }

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard let token = try await tokenProvider() else {
            return request
        }

        var modifiedRequest = request
        modifiedRequest.setValue(token, forHTTPHeaderField: headerName)
        return modifiedRequest
    }
}
