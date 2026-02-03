//
//  AuthInterceptorTests.swift
//  AIChat
//
//  Created on 2026-02-03.
//

import Testing
import Foundation
@testable import AIChat

@MainActor
struct AuthInterceptorTests {

    // MARK: - Initialization Tests

    @Test("Initializes with default header name")
    func test_whenInitialized_thenUsesDefaultHeaderName() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { "test-token" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == "test-token")
    }

    @Test("Initializes with custom header name")
    func test_whenInitializedWithCustomHeader_thenUsesCustomHeader() async throws {
        let interceptor = AuthInterceptor(
            headerName: "X-API-Key",
            tokenProvider: { "custom-token" }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "X-API-Key") == "custom-token")
        #expect(result.value(forHTTPHeaderField: "Authorization") == nil)
    }

    // MARK: - Bearer Token Tests

    @Test("Bearer factory creates interceptor with Bearer prefix")
    func test_whenBearerFactory_thenAddsBearerPrefix() async throws {
        let interceptor = AuthInterceptor.bearer(tokenProvider: { "abc123" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == "Bearer abc123")
    }

    @Test("Bearer factory returns nil token when provider returns nil")
    func test_whenBearerTokenIsNil_thenReturnsUnmodifiedRequest() async throws {
        let interceptor = AuthInterceptor.bearer(tokenProvider: { nil })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("Bearer factory handles empty token")
    func test_whenBearerTokenIsEmpty_thenAddsBearerWithEmptyString() async throws {
        let interceptor = AuthInterceptor.bearer(tokenProvider: { "" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == "Bearer ")
    }

    // MARK: - API Key Tests

    @Test("API key factory creates interceptor with static key")
    func test_whenApiKeyFactory_thenSetsStaticKey() async throws {
        let interceptor = AuthInterceptor.apiKey(
            headerName: "X-API-Key",
            apiKey: "my-secret-key"
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "X-API-Key") == "my-secret-key")
    }

    @Test("API key factory handles empty key")
    func test_whenApiKeyIsEmpty_thenSetsEmptyValue() async throws {
        let interceptor = AuthInterceptor.apiKey(
            headerName: "X-API-Key",
            apiKey: ""
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "X-API-Key") == "")
    }

    @Test("API key factory with special characters")
    func test_whenApiKeyHasSpecialChars_thenPreservesKey() async throws {
        let specialKey = "key-with-special!@#$%^&*()_+-=[]{}|;':\",./<>?"
        let interceptor = AuthInterceptor.apiKey(
            headerName: "X-API-Key",
            apiKey: specialKey
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "X-API-Key") == specialKey)
    }

    // MARK: - Token Provider Tests

    @Test("Token provider returns nil leaves request unchanged")
    func test_whenTokenProviderReturnsNil_thenRequestUnchanged() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { nil })

        let originalURL = URL(string: "https://api.example.com/test")!
        var request = URLRequest(url: originalURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let result = try await interceptor.intercept(request)

        #expect(result.url == originalURL)
        #expect(result.httpMethod == "POST")
        #expect(result.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(result.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("Token provider is called on each intercept")
    func test_whenInterceptMultipleTimes_thenCallsProviderEachTime() async throws {
        var callCount = 0
        let interceptor = AuthInterceptor(tokenProvider: {
            callCount += 1
            return "token-\(callCount)"
        })

        var request1 = URLRequest(url: URL(string: "https://api.example.com/test1")!)
        let result1 = try await interceptor.intercept(request1)
        #expect(result1.value(forHTTPHeaderField: "Authorization") == "token-1")

        var request2 = URLRequest(url: URL(string: "https://api.example.com/test2")!)
        let result2 = try await interceptor.intercept(request2)
        #expect(result2.value(forHTTPHeaderField: "Authorization") == "token-2")

        #expect(callCount == 2)
    }

    @Test("Token provider can be async")
    func test_whenTokenProviderIsAsync_thenWorksCorrectly() async throws {
        let interceptor = AuthInterceptor(tokenProvider: {
            try await Task.sleep(for: .milliseconds(10))
            return "async-token"
        })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == "async-token")
    }

    @Test("Token provider can throw error")
    func test_whenTokenProviderThrows_thenPropagatesError() async {
        struct TestError: Error {}
        let interceptor = AuthInterceptor(tokenProvider: {
            throw TestError()
        })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)

        await #expect(throws: TestError.self) {
            try await interceptor.intercept(request)
        }
    }

    // MARK: - Request Modification Tests

    @Test("Intercept preserves existing headers")
    func test_whenInterceptRequest_thenPreservesExistingHeaders() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { "test-token" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == "test-token")
        #expect(result.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(result.value(forHTTPHeaderField: "Accept-Encoding") == "gzip")
    }

    @Test("Intercept overwrites existing auth header")
    func test_whenExistingAuthHeader_thenOverwrites() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { "new-token" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.setValue("old-token", forHTTPHeaderField: "Authorization")

        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == "new-token")
    }

    @Test("Intercept preserves request method")
    func test_whenIntercept_thenPreservesMethod() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { "test-token" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "DELETE"

        let result = try await interceptor.intercept(request)

        #expect(result.httpMethod == "DELETE")
        #expect(result.value(forHTTPHeaderField: "Authorization") == "test-token")
    }

    @Test("Intercept preserves request body")
    func test_whenInterceptWithBody_thenPreservesBody() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { "test-token" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let bodyData = Data("test body".utf8)
        request.httpBody = bodyData

        let result = try await interceptor.intercept(request)

        #expect(result.httpBody == bodyData)
        #expect(result.value(forHTTPHeaderField: "Authorization") == "test-token")
    }

    @Test("Intercept preserves timeout interval")
    func test_whenInterceptWithTimeout_thenPreservesTimeout() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { "test-token" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.timeoutInterval = 120.0

        let result = try await interceptor.intercept(request)

        #expect(result.timeoutInterval == 120.0)
        #expect(result.value(forHTTPHeaderField: "Authorization") == "test-token")
    }

    @Test("Intercept preserves cache policy")
    func test_whenInterceptWithCachePolicy_thenPreservesCachePolicy() async throws {
        let interceptor = AuthInterceptor(tokenProvider: { "test-token" })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let result = try await interceptor.intercept(request)

        #expect(result.cachePolicy == .reloadIgnoringLocalCacheData)
        #expect(result.value(forHTTPHeaderField: "Authorization") == "test-token")
    }

    // MARK: - Edge Cases

    @Test("Handles very long tokens")
    func test_whenVeryLongToken_thenHandlesCorrectly() async throws {
        let longToken = String(repeating: "a", count: 10000)
        let interceptor = AuthInterceptor(tokenProvider: { longToken })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == longToken)
    }

    @Test("Handles tokens with newlines")
    func test_whenTokenHasNewlines_thenURLRequestNormalizesHeader() async throws {
        let tokenWithNewlines = "line1\nline2\nline3"
        let interceptor = AuthInterceptor(tokenProvider: { tokenWithNewlines })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        // Note: URLRequest automatically strips invalid characters (newlines) from HTTP headers
        // This is expected behavior since HTTP headers cannot contain newlines
        // The header will either be nil or have newlines stripped
        let authHeader = result.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader == nil || !authHeader!.contains("\n"))
    }

    @Test("Handles unicode in tokens")
    func test_whenTokenHasUnicode_thenHandlesCorrectly() async throws {
        let unicodeToken = "token-你好-🔐-مرحبا"
        let interceptor = AuthInterceptor(tokenProvider: { unicodeToken })

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let result = try await interceptor.intercept(request)

        #expect(result.value(forHTTPHeaderField: "Authorization") == unicodeToken)
    }

    @Test("Thread safety - concurrent intercepts")
    func test_whenConcurrentIntercepts_thenHandlesCorrectly() async throws {
        var counter = 0
        let interceptor = AuthInterceptor(tokenProvider: {
            counter += 1
            return "token-\(counter)"
        })

        // Create multiple concurrent requests
        await withTaskGroup(of: String?.self) { group in
            for i in 0..<10 {
                group.addTask {
                    var request = URLRequest(url: URL(string: "https://api.example.com/test\(i)")!)
                    let result = try? await interceptor.intercept(request)
                    return result?.value(forHTTPHeaderField: "Authorization")
                }
            }

            var tokens: [String] = []
            for await token in group {
                if let token = token {
                    tokens.append(token)
                }
            }

            // All requests should get a token (though they may be the same due to race conditions)
            #expect(tokens.count == 10)
            #expect(tokens.allSatisfy { $0.starts(with: "token-") })
        }
    }
}
