// LoggingInterceptorTests.swift
// NetworkKitTests

import Testing
import Foundation
@testable import NetworkKit

@Suite("LoggingInterceptor")
struct LoggingInterceptorTests {

    // MARK: - Test helpers

    /// A thread-safe log collector for use in `@Sendable` closures.
    ///
    /// Safety invariant: Each Swift Testing `@Test` function runs as a single
    /// async task; there is no concurrent access to `messages` within one test.
    /// `@unchecked Sendable` is therefore safe here and avoids fire-and-forget
    /// `Task`s or actors that would complicate assertions.
    private final class LogSpy: @unchecked Sendable {
        var messages: [String] = []
        func record(_ message: String) { messages.append(message) }
    }

    private func makeURLRequest(
        method: String = "GET",
        url: String = "https://api.example.com/test",
        headers: [String: String] = [:],
        body: Data? = nil
    ) throws -> URLRequest {
        var req = URLRequest(url: try #require(URL(string: url)))
        req.httpMethod = method
        req.httpBody = body
        for (k, v) in headers { req.setValue(v, forHTTPHeaderField: k) }
        return req
    }

    private func makeNetworkResponse(statusCode: Int = 200, body: String = "") -> NetworkResponse {
        NetworkResponse(
            data: Data(body.utf8),
            statusCode: statusCode,
            headers: ["Content-Type": "application/json"]
        )
    }

    // MARK: - Log level .none

    @Test("LogLevel.none emits nothing")
    func test_whenLogLevelNone_thenNothingLogged() async throws {
        let spy = LogSpy()
        let interceptor = LoggingInterceptor(logLevel: .none, logToConsole: false, customLogger: spy.record)

        _ = try await interceptor.intercept(try makeURLRequest())
        _ = try await interceptor.intercept(makeNetworkResponse())

        #expect(spy.messages.isEmpty)
    }

    // MARK: - Log level .basic

    @Test("LogLevel.basic logs method and URL")
    func test_whenLogLevelBasic_thenLogsMethodAndURL() async throws {
        let spy = LogSpy()
        let interceptor = LoggingInterceptor(logLevel: .basic, logToConsole: false, customLogger: spy.record)

        _ = try await interceptor.intercept(try makeURLRequest(method: "POST"))

        let combined = spy.messages.joined()
        #expect(combined.contains("POST"))
        #expect(combined.contains("api.example.com"))
    }

    @Test("LogLevel.basic logs status code in response")
    func test_whenLogLevelBasicResponse_thenLogsStatusCode() async throws {
        let spy = LogSpy()
        let interceptor = LoggingInterceptor(logLevel: .basic, logToConsole: false, customLogger: spy.record)

        _ = try await interceptor.intercept(makeNetworkResponse(statusCode: 404))

        #expect(spy.messages.joined().contains("404"))
    }

    // MARK: - Log level .headers

    @Test("LogLevel.headers logs header names")
    func test_whenLogLevelHeaders_thenLogsHeaders() async throws {
        let spy = LogSpy()
        let interceptor = LoggingInterceptor(logLevel: .headers, logToConsole: false, customLogger: spy.record)

        _ = try await interceptor.intercept(try makeURLRequest(headers: ["Accept": "application/json"]))

        #expect(spy.messages.joined().contains("Accept"))
    }

    @Test("Sensitive headers are masked")
    func test_whenSensitiveHeader_thenMasked() async throws {
        let spy = LogSpy()
        let interceptor = LoggingInterceptor(logLevel: .headers, logToConsole: false, customLogger: spy.record)

        _ = try await interceptor.intercept(try makeURLRequest(headers: ["Authorization": "Bearer secret"]))

        let combined = spy.messages.joined()
        #expect(combined.contains("***"))
        #expect(!combined.contains("Bearer secret"))
    }

    // MARK: - Log level .body

    @Test("LogLevel.body logs request body")
    func test_whenLogLevelBody_thenLogsBody() async throws {
        let spy = LogSpy()
        let interceptor = LoggingInterceptor(logLevel: .body, logToConsole: false, customLogger: spy.record)
        let bodyData = Data("{\"key\": \"value\"}".utf8)

        _ = try await interceptor.intercept(try makeURLRequest(body: bodyData))

        #expect(spy.messages.joined().contains("key"))
    }

    @Test("LogLevel.body logs response body")
    func test_whenLogLevelBodyResponse_thenLogsBody() async throws {
        let spy = LogSpy()
        let interceptor = LoggingInterceptor(logLevel: .body, logToConsole: false, customLogger: spy.record)

        _ = try await interceptor.intercept(makeNetworkResponse(body: "{\"result\": true}"))

        #expect(spy.messages.joined().contains("result"))
    }

    // MARK: - Pass-through

    @Test("Request is returned unchanged")
    func test_whenIntercept_thenRequestUnchanged() async throws {
        let interceptor = LoggingInterceptor(logLevel: .body, logToConsole: false)
        let original = try makeURLRequest(method: "DELETE")
        let result = try await interceptor.intercept(original)
        #expect(result.httpMethod == original.httpMethod)
        #expect(result.url == original.url)
    }

    @Test("Response is returned unchanged")
    func test_whenInterceptResponse_thenResponseUnchanged() async throws {
        let interceptor = LoggingInterceptor(logLevel: .body, logToConsole: false)
        let original = makeNetworkResponse(statusCode: 201, body: "created")
        let result = try await interceptor.intercept(original)
        #expect(result.statusCode == original.statusCode)
        #expect(result.string() == original.string())
    }

    // MARK: - LogLevel Comparable

    @Test("LogLevel ordering is correct")
    func test_whenComparingLogLevels_thenCorrectOrder() {
        #expect(LoggingInterceptor.LogLevel.none < .basic)
        #expect(LoggingInterceptor.LogLevel.basic < .headers)
        #expect(LoggingInterceptor.LogLevel.headers < .body)
    }
}
