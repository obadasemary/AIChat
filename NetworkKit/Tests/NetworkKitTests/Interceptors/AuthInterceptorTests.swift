// AuthInterceptorTests.swift
// NetworkKitTests

import Testing
import Foundation
@testable import NetworkKit

@Suite("AuthInterceptor")
struct AuthInterceptorTests {

    private func makeRequest(url: String = "https://api.example.com/data") throws -> URLRequest {
        URLRequest(url: try #require(URL(string: url)))
    }

    // MARK: - Bearer token

    @Test("Bearer factory injects Authorization header with Bearer prefix")
    func test_whenBearerToken_thenInjectsAuthorizationHeader() async throws {
        let interceptor = AuthInterceptor.bearer { "test-token" }
        let result = try await interceptor.intercept(makeRequest())
        #expect(result.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    }

    @Test("Bearer factory skips header when token provider returns nil")
    func test_whenTokenProviderReturnsNil_thenNoHeader() async throws {
        let interceptor = AuthInterceptor.bearer { nil }
        let result = try await interceptor.intercept(makeRequest())
        #expect(result.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("Bearer factory propagates token provider errors")
    func test_whenTokenProviderThrows_thenPropagatesError() async throws {
        struct AuthError: Error {}
        let interceptor = AuthInterceptor.bearer { throw AuthError() }
        await #expect(throws: AuthError.self) {
            _ = try await interceptor.intercept(makeRequest())
        }
    }

    // MARK: - API key

    @Test("apiKey factory injects the given header")
    func test_whenAPIKey_thenInjectsHeader() async throws {
        let interceptor = AuthInterceptor.apiKey(headerName: "X-Api-Key", apiKey: "secret-key")
        let result = try await interceptor.intercept(makeRequest())
        #expect(result.value(forHTTPHeaderField: "X-Api-Key") == "secret-key")
    }

    // MARK: - Custom header name

    @Test("Custom headerName is used")
    func test_whenCustomHeaderName_thenUsesCustomName() async throws {
        let interceptor = AuthInterceptor(headerName: "X-Custom-Auth") { "my-value" }
        let result = try await interceptor.intercept(makeRequest())
        #expect(result.value(forHTTPHeaderField: "X-Custom-Auth") == "my-value")
    }

    // MARK: - Existing headers preserved

    @Test("Existing headers on the request are preserved")
    func test_whenRequestHasExistingHeaders_thenPreserved() async throws {
        var request = try makeRequest()
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let interceptor = AuthInterceptor.bearer { "token" }
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(result.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    }
}
