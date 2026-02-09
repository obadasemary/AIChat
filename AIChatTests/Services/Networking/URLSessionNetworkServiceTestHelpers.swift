//
//  URLSessionNetworkServiceTestHelpers.swift
//  AIChat
//
//  Created on 2026-02-03.
//

import Foundation
@testable import AIChat

// MARK: - Test Helpers

/// Mock URLProtocol for testing network requests
final class MockURLProtocol: URLProtocol {
    private static let lock = NSLock()
    private static var _requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _requestHandler
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _requestHandler = newValue
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        // Get the handler
        let handler = MockURLProtocol.requestHandler

        guard let handler = handler else {
            // Return a default 200 response if no handler is set
            guard let url = request.url,
                  let response = HTTPURLResponse(
                      url: url,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                fatalError("Failed to create default mock response")
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data())
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // No-op
    }
}

/// Test request interceptor that adds a header
/// - Note: @unchecked Sendable is safe here because test suites are serialized (@Suite(.serialized))
///   and instances are never shared across concurrent tests.
final class TestRequestInterceptor: RequestInterceptor, @unchecked Sendable {
    let headerKey: String
    let headerValue: String
    var interceptCalled = false

    init(headerKey: String, headerValue: String) {
        self.headerKey = headerKey
        self.headerValue = headerValue
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        interceptCalled = true
        var modifiedRequest = request
        modifiedRequest.setValue(headerValue, forHTTPHeaderField: headerKey)
        return modifiedRequest
    }
}

/// Test response interceptor that tracks calls
/// - Note: @unchecked Sendable is safe here because test suites are serialized (@Suite(.serialized))
///   and instances are never shared across concurrent tests.
final class TestResponseInterceptor: ResponseInterceptor, @unchecked Sendable {
    let statusCodeModifier: Int
    var interceptCalled = false

    init(statusCodeModifier: Int = 0) {
        self.statusCodeModifier = statusCodeModifier
    }

    func intercept(_ response: NetworkResponse) async throws -> NetworkResponse {
        interceptCalled = true
        return response
    }
}

/// Helper class to track ordering of interceptor calls
final class OrderTracker: @unchecked Sendable {
    private var _order: [Int] = []
    private let lock = NSLock()

    var order: [Int] {
        lock.lock()
        defer { lock.unlock() }
        return _order
    }

    func append(_ id: Int) {
        lock.lock()
        defer { lock.unlock() }
        _order.append(id)
    }
}

/// Test request interceptor that tracks order
final class OrderedRequestInterceptor: RequestInterceptor {
    let id: Int
    let orderTracker: OrderTracker

    init(id: Int, orderTracker: OrderTracker) {
        self.id = id
        self.orderTracker = orderTracker
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        orderTracker.append(id)
        return request
    }
}

/// Test response interceptor that tracks order
final class OrderedResponseInterceptor: ResponseInterceptor {
    let id: Int
    let orderTracker: OrderTracker

    init(id: Int, orderTracker: OrderTracker) {
        self.id = id
        self.orderTracker = orderTracker
    }

    func intercept(_ response: NetworkResponse) async throws -> NetworkResponse {
        orderTracker.append(id)
        return response
    }
}

/// Test response interceptor that throws an error
final class ErrorThrowingResponseInterceptor: ResponseInterceptor {
    func intercept(_ response: NetworkResponse) async throws -> NetworkResponse {
        throw NetworkError.unauthorized
    }
}

/// Creates a URL session configuration for testing with MockURLProtocol
func createMockConfiguration() -> URLSessionConfiguration {
    let config = URLSessionConfiguration.default
    config.protocolClasses = [MockURLProtocol.self]
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    return config
}
