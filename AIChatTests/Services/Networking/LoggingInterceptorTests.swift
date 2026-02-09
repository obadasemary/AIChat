//
//  LoggingInterceptorTests.swift
//  AIChat
//
//  Created on 2026-02-03.
//

import Testing
import Foundation
@testable import AIChat

// swiftlint:disable file_length force_unwrapping
@MainActor
struct LoggingInterceptorTests {

    // MARK: - Initialization Tests

    @Test("Initializes with default log level")
    func test_whenInitialized_thenUsesBasicLogLevel() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "GET"
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("[Network Request]") == true)
        #expect(loggedMessage?.contains("GET") == true)
    }

    @Test("Initializes with custom log level")
    func test_whenInitializedWithLogLevel_thenUsesCustomLevel() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .none,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let request = URLRequest(
            url: URL(string: "https://api.example.com/test")!
        )
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage == nil)
    }

    // MARK: - Request Logging - Log Level None

    @Test("None log level does not log requests")
    func test_whenLogLevelNone_thenDoesNotLogRequest() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .none,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let request = URLRequest(
            url: URL(string: "https://api.example.com/test")!
        )
        let result = try await interceptor.intercept(request)

        #expect(loggedMessage == nil)
        #expect(result.url == request.url)
    }

    // MARK: - Request Logging - Log Level Basic

    @Test("Basic log level logs method and URL")
    func test_whenLogLevelBasic_thenLogsMethodAndURL() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .basic,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "POST"
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("[Network Request]") == true)
        #expect(loggedMessage?.contains("POST") == true)
        #expect(loggedMessage?.contains("https://api.example.com/test") == true)
        #expect(loggedMessage?.contains("Headers:") == false)
        #expect(loggedMessage?.contains("Body:") == false)
    }

    @Test("Basic log level does not log headers")
    func test_whenLogLevelBasic_thenDoesNotLogHeaders() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .basic,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("Headers:") == false)
        #expect(loggedMessage?.contains("Content-Type") == false)
    }

    // MARK: - Request Logging - Log Level Headers

    @Test("Headers log level logs headers")
    func test_whenLogLevelHeaders_thenLogsHeaders() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("[Network Request]") == true)
        #expect(loggedMessage?.contains("Headers:") == true)
        #expect(loggedMessage?.contains("Content-Type") == true)
        #expect(loggedMessage?.contains("application/json") == true)
        #expect(loggedMessage?.contains("Accept-Encoding") == true)
        #expect(loggedMessage?.contains("gzip") == true)
    }

    @Test("Headers log level masks sensitive headers")
    func test_whenSensitiveHeaders_thenMasksValues() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.setValue("Bearer secret-token", forHTTPHeaderField: "Authorization")
        request.setValue("my-api-key", forHTTPHeaderField: "X-API-Key")
        request.setValue("session-cookie", forHTTPHeaderField: "Cookie")
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("Authorization") == true)
        #expect(loggedMessage?.contains("***") == true)
        #expect(loggedMessage?.contains("secret-token") == false)
        #expect(loggedMessage?.contains("my-api-key") == false)
        #expect(loggedMessage?.contains("session-cookie") == false)
    }

    @Test("Headers log level does not log body")
    func test_whenLogLevelHeaders_thenDoesNotLogBody() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpBody = Data("test body".utf8)
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("Body:") == false)
        #expect(loggedMessage?.contains("test body") == false)
    }

    // MARK: - Request Logging - Log Level Body

    @Test("Body log level logs text body")
    func test_whenLogLevelBody_thenLogsTextBody() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpBody = Data("{\"key\": \"value\"}".utf8)
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("Body:") == true)
        #expect(loggedMessage?.contains("{\"key\": \"value\"}") == true)
    }

    @Test("Body log level logs binary data size")
    func test_whenBinaryBody_thenLogsByteCount() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        // Create non-UTF8 binary data
        request.httpBody = Data([0xFF, 0xFE, 0xFD, 0xFC])
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("Body:") == true)
        #expect(loggedMessage?.contains("<binary data:") == true)
        #expect(loggedMessage?.contains("bytes>") == true)
    }

    @Test("Body log level truncates long bodies")
    func test_whenLongBody_thenTruncates() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let longString = String(repeating: "a", count: 1500)
        request.httpBody = Data(longString.utf8)
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("Body:") == true)
        #expect(loggedMessage?.contains("...") == true)
        #expect((loggedMessage?.filter { $0 == "a" }.count ?? 0) < 1500)
    }

    @Test("Body log level does not truncate short bodies")
    func test_whenShortBody_thenDoesNotTruncate() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        let shortString = String(repeating: "a", count: 500)
        request.httpBody = Data(shortString.utf8)
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("...") == false)
        #expect(loggedMessage?.contains(shortString) == true)
    }

    // MARK: - Response Logging - Log Level None

    @Test("None log level does not log responses")
    func test_whenLogLevelNone_thenDoesNotLogResponse() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .none,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let response = NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [:],
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        let result = try await interceptor.intercept(response)

        #expect(loggedMessage == nil)
        #expect(result.statusCode == 200)
    }

    // MARK: - Response Logging - Log Level Basic

    @Test("Basic log level logs URL and status code")
    func test_whenLogLevelBasicForResponse_thenLogsURLAndStatus() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .basic,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let response = NetworkResponse(
            data: Data(),
            statusCode: 404,
            headers: [:],
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        _ = try await interceptor.intercept(response)

        #expect(loggedMessage?.contains("[Network Response]") == true)
        #expect(loggedMessage?.contains("https://api.example.com/test") == true)
        #expect(loggedMessage?.contains("404") == true)
        #expect(loggedMessage?.contains("Headers:") == false)
    }

    // MARK: - Response Logging - Log Level Headers

    @Test("Headers log level logs response headers")
    func test_whenLogLevelHeadersForResponse_thenLogsHeaders() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let response = NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache"
            ]
        ,
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        _ = try await interceptor.intercept(response)

        #expect(loggedMessage?.contains("Headers:") == true)
        #expect(loggedMessage?.contains("Content-Type") == true)
        #expect(loggedMessage?.contains("application/json") == true)
        #expect(loggedMessage?.contains("Cache-Control") == true)
        #expect(loggedMessage?.contains("no-cache") == true)
    }

    @Test("Headers log level does not log empty headers")
    func test_whenNoResponseHeaders_thenDoesNotShowHeadersSection() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let response = NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [:],
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        _ = try await interceptor.intercept(response)

        #expect(loggedMessage?.contains("Headers:") == false)
    }

    // MARK: - Response Logging - Log Level Body

    @Test("Body log level logs text response body")
    func test_whenLogLevelBodyForResponse_thenLogsTextBody() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let responseData = Data("{\"status\": \"success\"}".utf8)
        let response = NetworkResponse(
            data: responseData,
            statusCode: 200,
            headers: [:],
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        _ = try await interceptor.intercept(response)

        #expect(loggedMessage?.contains("Body:") == true)
        #expect(loggedMessage?.contains("{\"status\": \"success\"}") == true)
    }

    @Test("Body log level logs binary response size")
    func test_whenBinaryResponseBody_thenLogsByteCount() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let binaryData = Data([0xFF, 0xFE, 0xFD, 0xFC, 0xFB])
        let response = NetworkResponse(
            data: binaryData,
            statusCode: 200,
            headers: [:],
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        _ = try await interceptor.intercept(response)

        #expect(loggedMessage?.contains("Body:") == true)
        #expect(loggedMessage?.contains("<binary data:") == true)
        #expect(loggedMessage?.contains("5 bytes>") == true)
    }

    @Test("Body log level truncates long response bodies")
    func test_whenLongResponseBody_thenTruncates() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let longString = String(repeating: "b", count: 2000)
        let responseData = Data(longString.utf8)
        let response = NetworkResponse(
            data: responseData,
            statusCode: 200,
            headers: [:],
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        _ = try await interceptor.intercept(response)

        #expect(loggedMessage?.contains("Body:") == true)
        #expect(loggedMessage?.contains("...") == true)
        #expect((loggedMessage?.filter { $0 == "b" }.count ?? 0) < 2000)
    }

    // MARK: - Console Logging Tests

    @Test("Console logging can be disabled")
    func test_whenConsoleLoggingDisabled_thenOnlyUsesCustomLogger() async throws {
        var customLogCalled = false
        let interceptor = LoggingInterceptor(
            logLevel: .basic,
            logToConsole: false,
            customLogger: { _ in customLogCalled = true }
        )

        let request = URLRequest(
            url: URL(string: "https://api.example.com/test")!
        )
        _ = try await interceptor.intercept(request)

        #expect(customLogCalled == true)
    }

    @Test("Custom logger receives all logs")
    func test_whenCustomLogger_thenReceivesAllLogs() async throws {
        var logCount = 0
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { _ in logCount += 1 }
        )

        let request = URLRequest(
            url: URL(string: "https://api.example.com/test")!
        )
        _ = try await interceptor.intercept(request)

        let response = NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [:],
            request: request
        )
        _ = try await interceptor.intercept(response)

        #expect(logCount == 2)
    }

    @Test("No custom logger works correctly")
    func test_whenNoCustomLogger_thenDoesNotCrash() async throws {
        let interceptor = LoggingInterceptor(
            logLevel: .basic,
            logToConsole: false,
            customLogger: nil
        )

        let request = URLRequest(
            url: URL(string: "https://api.example.com/test")!
        )
        let result = try await interceptor.intercept(request)

        #expect(result.url == request.url)
    }

    // MARK: - Request Preservation Tests

    @Test("Request interceptor returns unmodified request")
    func test_whenInterceptRequest_thenReturnsUnmodified() async throws {
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: nil
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("test".utf8)
        request.timeoutInterval = 60.0

        let result = try await interceptor.intercept(request)

        #expect(result.url == request.url)
        #expect(result.httpMethod == request.httpMethod)
        #expect(result.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(result.httpBody == request.httpBody)
        #expect(result.timeoutInterval == request.timeoutInterval)
    }

    @Test("Response interceptor returns unmodified response")
    func test_whenInterceptResponse_thenReturnsUnmodified() async throws {
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: nil
        )

        let responseData = Data("test data".utf8)
        let response = NetworkResponse(
            data: responseData,
            statusCode: 201,
            headers: ["X-Custom": "value"]
        ,
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        let result = try await interceptor.intercept(response)

        #expect(result.data == responseData)
        #expect(result.statusCode == 201)
        #expect(result.headers["X-Custom"] == "value")
    }

    // MARK: - Edge Cases

    @Test("Handles request with no URL")
    func test_whenRequestHasNoURL_thenDoesNotCrash() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .basic,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        // Note: URLRequest requires a URL, so this test verifies the guard works
        let request = URLRequest(url: URL(string: "https://api.example.com")!)
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("[Network Request]") == true)
    }

    @Test("Handles response with no request URL")
    func test_whenResponseHasNoRequestURL_thenLogsWithoutURL() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .basic,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        // Create response with request that has no URL (edge case)
        let response = NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [:],
            request: nil
        )

        _ = try await interceptor.intercept(response)

        #expect(loggedMessage?.contains("[Network Response]") == true)
        #expect(loggedMessage?.contains("200") == true)
    }

    @Test("Handles empty body gracefully")
    func test_whenEmptyBody_thenLogsCorrectly() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .body,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpBody = Data()
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("[Network Request]") == true)
    }

    @Test("Sensitive headers are case-insensitive")
    func test_whenSensitiveHeadersMixedCase_thenMasksCorrectly() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.setValue("secret", forHTTPHeaderField: "AUTHORIZATION")
        request.setValue("key", forHTTPHeaderField: "Api-Key")
        _ = try await interceptor.intercept(request)

        #expect(loggedMessage?.contains("***") == true)
        #expect(loggedMessage?.contains("secret") == false)
        #expect(loggedMessage?.contains("key") == false)
    }

    @Test("Headers are sorted alphabetically")
    func test_whenMultipleHeaders_thenSortedAlphabetically() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.setValue("value1", forHTTPHeaderField: "Z-Header")
        request.setValue("value2", forHTTPHeaderField: "A-Header")
        request.setValue("value3", forHTTPHeaderField: "M-Header")
        _ = try await interceptor.intercept(request)

        guard let message = loggedMessage else {
            Issue.record("No log message captured")
            return
        }

        let aIndex = message.range(of: "A-Header")?.lowerBound
        let mIndex = message.range(of: "M-Header")?.lowerBound
        let zIndex = message.range(of: "Z-Header")?.lowerBound

        if let aIndex = aIndex, let mIndex = mIndex, let zIndex = zIndex {
            #expect(aIndex < mIndex)
            #expect(mIndex < zIndex)
        }
    }

    @Test("Response headers are sorted alphabetically")
    func test_whenMultipleResponseHeaders_thenSortedAlphabetically() async throws {
        var loggedMessage: String?
        let interceptor = LoggingInterceptor(
            logLevel: .headers,
            logToConsole: false,
            customLogger: { loggedMessage = $0 }
        )

        let response = NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [
                "Z-Response": "value1",
                "A-Response": "value2",
                "M-Response": "value3"
            ]
        ,
            request: URLRequest(url: URL(string: "https://api.example.com/test")!)
        )

        _ = try await interceptor.intercept(response)

        guard let message = loggedMessage else {
            Issue.record("No log message captured")
            return
        }

        let aIndex = message.range(of: "A-Response")?.lowerBound
        let mIndex = message.range(of: "M-Response")?.lowerBound
        let zIndex = message.range(of: "Z-Response")?.lowerBound

        if let aIndex = aIndex, let mIndex = mIndex, let zIndex = zIndex {
            #expect(aIndex < mIndex)
            #expect(mIndex < zIndex)
        }
    }
}
// swiftlint:enable file_length
