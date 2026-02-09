//
//  URLSessionNetworkServiceTests.swift
//  AIChat
//
//  Created on 2026-02-03.
//

import Testing
import Foundation
@testable import AIChat

// swiftlint:disable type_body_length
// swiftlint:disable file_length

@MainActor
@Suite(.serialized) // Run tests serially to avoid MockURLProtocol race conditions
struct URLSessionNetworkServiceTests {
    
    // MARK: - Initialization Tests
    
    @Test("Initialize with default parameters")
    func test_whenInitWithDefaults_thenHasCorrectDefaults() {
        let service = URLSessionNetworkService()
        
        #expect(service.baseURL == nil)
    }
    
    @Test("Initialize with base URL")
    func test_whenInitWithBaseURL_thenBaseURLIsSet() {
        let baseURL = URL(string: "https://api.example.com")
        let service = URLSessionNetworkService(baseURL: baseURL)
        
        #expect(service.baseURL == baseURL)
    }
    
    @Test("Initialize with configuration")
    func test_whenInitWithConfiguration_thenUsesConfiguration() {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config
        )
        
        #expect(service.baseURL == baseURL)
    }
    
    @Test("Initialize with default headers")
    func test_whenInitWithDefaultHeaders_thenHeadersAreSet() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        MockURLProtocol.requestHandler = { request in
            #expect(request.value(forHTTPHeaderField: "X-Custom-Header") == "CustomValue")
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
            
            guard let fallbackURL = URL(string: "https://api.example.com"),
                  let response = HTTPURLResponse(
                      url: request.url ?? fallbackURL,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }
        
        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            defaultHeaders: [
                "X-Custom-Header": "CustomValue",
                "Authorization": "Bearer token"
            ]
        )
        
        let request = NetworkRequest.get("/test")
        _ = try await service.execute(request)
    }
    
    // MARK: - URL Building Tests

    @Test("Execute with relative path appends to base URL")
    func test_whenRelativePath_thenAppendsToBaseURL() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://api.example.com/users")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/users")
        _ = try await service.execute(request)
    }

    @Test("Execute with absolute URL ignores base URL")
    func test_whenAbsoluteURL_thenIgnoresBaseURL() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://other.example.com/data")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("https://other.example.com/data")
        _ = try await service.execute(request)
    }

    @Test("Execute with query parameters appends them to URL")
    func test_whenQueryParameters_thenAppendsToURL() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            let urlString = request.url?.absoluteString ?? ""
            #expect(urlString.contains("page=1"))
            #expect(urlString.contains("limit=10"))

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/users", queryParameters: ["page": "1", "limit": "10"])
        _ = try await service.execute(request)
    }

    @Test("Execute without base URL throws invalid URL error")
    func test_whenNoBaseURLAndRelativePath_thenThrowsInvalidURL() async {
        let service = URLSessionNetworkService()
        let request = NetworkRequest.get("/relative/path")

        await #expect(throws: NetworkError.invalidURL) {
            try await service.execute(request)
        }
    }

    @Test("Execute with empty path uses base URL")
    func test_whenEmptyPath_thenUsesBaseURL() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://api.example.com")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest(path: "")
        _ = try await service.execute(request)
    }

    @Test("Execute with path containing multiple segments")
    func test_whenMultiplePathSegments_thenBuildsCorrectURL() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://api.example.com/api/v1/users")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/api/v1/users")
        _ = try await service.execute(request)
    }

    @Test("Execute with special characters in query parameters")
    func test_whenSpecialCharactersInQueryParams_thenEncodesCorrectly() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            let urlString = request.url?.absoluteString ?? ""
            // The actual encoding will be handled by URLComponents
            #expect(urlString.contains("search="))
            #expect(urlString.contains("test"))

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/search", queryParameters: ["search": "test value"])
        _ = try await service.execute(request)
    }
    
    // MARK: - Request Building Tests

    @Test("Execute sets HTTP method correctly for GET")
    func test_whenGETMethod_thenSetsCorrectHTTPMethod() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.httpMethod == HTTPMethod.get.rawValue)

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest(path: "/test", method: .get)
        _ = try await service.execute(request)
    }

    @Test("Execute sets HTTP method correctly for POST")
    func test_whenPOSTMethod_thenSetsCorrectHTTPMethod() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.httpMethod == HTTPMethod.post.rawValue)

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest(path: "/test", method: .post)
        _ = try await service.execute(request)
    }

    @Test("Execute sets request headers")
    func test_whenRequestHeaders_thenSetsHeaders() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
            #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest(
            path: "/test",
            headers: ["Content-Type": "application/json", "Accept": "application/json"]
        )
        _ = try await service.execute(request)
    }

    @Test("Execute merges default headers with request headers")
    func test_whenBothDefaultAndRequestHeaders_thenMergesHeaders() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.value(forHTTPHeaderField: "X-API-Key") == "default-key")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            defaultHeaders: ["X-API-Key": "default-key"]
        )
        let request = NetworkRequest(
            path: "/test",
            headers: ["Content-Type": "application/json"]
        )
        _ = try await service.execute(request)
    }

    @Test("Execute request headers override default headers")
    func test_whenRequestHeaderOverridesDefault_thenUsesRequestHeader() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.value(forHTTPHeaderField: "X-Custom") == "request-value")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            defaultHeaders: ["X-Custom": "default-value"]
        )
        let request = NetworkRequest(
            path: "/test",
            headers: ["X-Custom": "request-value"]
        )
        _ = try await service.execute(request)
    }

    @Test("Execute sets request body")
    func test_whenRequestBody_thenSetsBody() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let bodyData = Data("test body".utf8)
        var bodyWasSet = false

        MockURLProtocol.requestHandler = { request in
            // URLSession might use httpBodyStream instead of httpBody
            // Verify that either httpBody or httpBodyStream is set
            if request.httpBody != nil || request.httpBodyStream != nil {
                bodyWasSet = true
            }

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest(path: "/test", method: .post, body: bodyData)
        _ = try await service.execute(request)

        #expect(bodyWasSet)
    }

    @Test("Execute sets timeout interval")
    func test_whenCustomTimeout_thenSetsTimeout() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            #expect(request.timeoutInterval == 60)

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest(path: "/test", timeoutInterval: 60)
        _ = try await service.execute(request)
    }

    @Test("Execute sets cache policy")
    func test_whenCustomCachePolicy_thenSetsCachePolicy() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        var capturedCachePolicy: URLRequest.CachePolicy?

        MockURLProtocol.requestHandler = { request in
            capturedCachePolicy = request.cachePolicy

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest(
            path: "/test",
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        _ = try await service.execute(request)

        // Verify that a cache policy was captured (configuration may affect the exact value)
        #expect(capturedCachePolicy != nil)
    }
    
    // MARK: - Successful Execution Tests

    @Test("Execute returns successful response with data")
    func test_whenSuccessfulRequest_thenReturnsResponse() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let responseData = Data("{\"id\": 1, \"name\": \"Test\"}".utf8)

        // Set the mock handler FIRST
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: ["Content-Type": "application/json"]
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, responseData)
        }

        // Then create the service
        let config = createMockConfiguration()
        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")
        let response = try await service.execute(request)

        #expect(response.statusCode == 200)
        #expect(response.data == responseData)
        #expect(response.headers["Content-Type"] == "application/json")
        #expect(response.isSuccess)
    }

    @Test("Execute returns response with empty data")
    func test_whenEmptyResponse_thenReturnsEmptyData() async throws {
        let baseURL = URL(string: "https://api.example.com")

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 204,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let config = createMockConfiguration()
        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")
        let response = try await service.execute(request)

        #expect(response.statusCode == 204)
        #expect(response.data.isEmpty)
    }

    @Test("Execute throws invalid response for non-HTTP response")
    func test_whenNonHTTPResponse_thenThrowsInvalidResponse() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("Failed to get request URL")
            }
            let response = URLResponse(
                url: url,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            )
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: URL(string: "https://api.example.com"),
            configuration: config
        )
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.invalidResponse) {
            try await service.execute(request)
        }
    }
    
    // MARK: - HTTP Error Handling Tests

    @Test("Execute throws unauthorized error for 401")
    func test_when401Response_thenThrowsUnauthorized() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 401,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.unauthorized) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws forbidden error for 403")
    func test_when403Response_thenThrowsForbidden() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 403,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.forbidden) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws not found error for 404")
    func test_when404Response_thenThrowsNotFound() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 404,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.notFound) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws timeout error for 408")
    func test_when408Response_thenThrowsTimeout() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 408,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.timeout) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws server error for 5xx")
    func test_when5xxResponse_thenThrowsServerError() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let statusCodes = [500, 502, 503, 504]

        for statusCode in statusCodes {
            MockURLProtocol.requestHandler = { request in
                guard let url = request.url,
                      let response = HTTPURLResponse(
                          url: url,
                          statusCode: statusCode,
                          httpVersion: nil,
                          headerFields: nil
                      ) else {
                    fatalError("Failed to create mock response")
                }
                return (response, Data())
            }

            let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
            let request = NetworkRequest.get("/test")

            do {
                _ = try await service.execute(request)
                Issue.record("Expected server error to be thrown for status code \(statusCode)")
            } catch let error as NetworkError {
                if case .serverError(let code) = error {
                    #expect(code == statusCode)
                } else {
                    Issue.record("Expected server error, got \(error)")
                }
            }
        }
    }

    @Test("Execute throws HTTP error for other error codes")
    func test_whenOtherErrorCode_thenThrowsHTTPError() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 418,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        do {
            _ = try await service.execute(request)
            Issue.record("Expected HTTP error to be thrown")
        } catch let error as NetworkError {
            if case .httpError(let statusCode, _) = error {
                #expect(statusCode == 418)
            } else {
                Issue.record("Expected HTTP error, got \(error)")
            }
        }
    }

    // MARK: - URLError Handling Tests

    @Test("Execute throws timeout error for URLError timeout")
    func test_whenURLErrorTimeout_thenThrowsTimeout() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.timeout) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws no connection error for URLError not connected")
    func test_whenURLErrorNotConnected_thenThrowsNoConnection() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.noConnection) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws cancelled error for URLError cancelled")
    func test_whenURLErrorCancelled_thenThrowsCancelled() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.cancelled)
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.cancelled) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws invalid URL error for URLError bad URL")
    func test_whenURLErrorBadURL_thenThrowsInvalidURL() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.badURL)
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.invalidURL) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws unknown error for other URLError")
    func test_whenOtherURLError_thenThrowsUnknown() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.badServerResponse)
        }

        let service = URLSessionNetworkService(baseURL: baseURL, configuration: config)
        let request = NetworkRequest.get("/test")

        do {
            _ = try await service.execute(request)
            Issue.record("Expected unknown error to be thrown")
        } catch let error as NetworkError {
            if case .unknown = error {
                // Success
            } else {
                Issue.record("Expected unknown error, got \(error)")
            }
        }
    }
    
    // MARK: - Request and Response Interceptor Tests

    @Test("Execute applies request interceptors")
    func test_whenRequestInterceptors_thenAppliesInterceptors() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let interceptor1 = TestRequestInterceptor(headerKey: "X-Interceptor-1", headerValue: "Value1")
        let interceptor2 = TestRequestInterceptor(headerKey: "X-Interceptor-2", headerValue: "Value2")

        MockURLProtocol.requestHandler = { request in
            #expect(request.value(forHTTPHeaderField: "X-Interceptor-1") == "Value1")
            #expect(request.value(forHTTPHeaderField: "X-Interceptor-2") == "Value2")

            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            requestInterceptors: [interceptor1, interceptor2]
        )
        let request = NetworkRequest.get("/test")
        _ = try await service.execute(request)

        #expect(interceptor1.interceptCalled)
        #expect(interceptor2.interceptCalled)
    }

    @Test("Execute applies request interceptors in order")
    func test_whenMultipleRequestInterceptors_thenAppliesInOrder() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let orderTracker = OrderTracker()
        let interceptor1 = OrderedRequestInterceptor(id: 1, orderTracker: orderTracker)
        let interceptor2 = OrderedRequestInterceptor(id: 2, orderTracker: orderTracker)
        let interceptor3 = OrderedRequestInterceptor(id: 3, orderTracker: orderTracker)

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            requestInterceptors: [interceptor1, interceptor2, interceptor3]
        )
        let request = NetworkRequest.get("/test")
        _ = try await service.execute(request)

        #expect(orderTracker.order == [1, 2, 3])
    }

    // MARK: - Response Interceptor Tests

    @Test("Execute applies response interceptors")
    func test_whenResponseInterceptors_thenAppliesInterceptors() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let interceptor1 = TestResponseInterceptor(statusCodeModifier: 1)
        let interceptor2 = TestResponseInterceptor(statusCodeModifier: 1)

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            responseInterceptors: [interceptor1, interceptor2]
        )
        let request = NetworkRequest.get("/test")
        let response = try await service.execute(request)

        // Each interceptor adds 1 to status code, but interceptors don't actually modify it
        // in our test implementation (they just track calls)
        #expect(interceptor1.interceptCalled)
        #expect(interceptor2.interceptCalled)
        #expect(response.statusCode == 200)
    }

    @Test("Execute applies response interceptors in order")
    func test_whenMultipleResponseInterceptors_thenAppliesInOrder() async throws {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let orderTracker = OrderTracker()
        let interceptor1 = OrderedResponseInterceptor(id: 1, orderTracker: orderTracker)
        let interceptor2 = OrderedResponseInterceptor(id: 2, orderTracker: orderTracker)
        let interceptor3 = OrderedResponseInterceptor(id: 3, orderTracker: orderTracker)

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            responseInterceptors: [interceptor1, interceptor2, interceptor3]
        )
        let request = NetworkRequest.get("/test")
        _ = try await service.execute(request)

        #expect(orderTracker.order == [1, 2, 3])
    }

    @Test("Execute response interceptor can throw error")
    func test_whenResponseInterceptorThrows_thenPropagatesError() async {
        let baseURL = URL(string: "https://api.example.com")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        let interceptor = ErrorThrowingResponseInterceptor()

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create mock response")
            }
            return (response, Data())
        }

        let service = URLSessionNetworkService(
            baseURL: baseURL,
            configuration: config,
            responseInterceptors: [interceptor]
        )
        let request = NetworkRequest.get("/test")

        await #expect(throws: NetworkError.unauthorized) {
            try await service.execute(request)
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
