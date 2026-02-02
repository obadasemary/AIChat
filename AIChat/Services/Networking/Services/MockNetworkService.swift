//
//  MockNetworkService.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Mock implementation of NetworkServiceProtocol for testing
final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    /// The base URL (not used in mock but required by protocol)
    let baseURL: URL?

    /// Simulated network delay in seconds
    private let delay: TimeInterval

    /// Whether to simulate errors
    private let shouldError: Bool

    /// The error to throw when shouldError is true
    private let errorToThrow: NetworkError

    /// Mock responses keyed by path
    private var mockResponses: [String: MockResponse]

    /// Recorded requests for verification
    private(set) var recordedRequests: [NetworkRequest] = []

    /// A mock response configuration
    struct MockResponse: Sendable {
        let data: Data
        let statusCode: Int
        let headers: [String: String]

        init(
            data: Data,
            statusCode: Int = 200,
            headers: [String: String] = [:]
        ) {
            self.data = data
            self.statusCode = statusCode
            self.headers = headers
        }

        /// Creates a mock response from an Encodable object
        static func json<T: Encodable>(
            _ object: T,
            statusCode: Int = 200,
            encoder: JSONEncoder = JSONEncoder()
        ) throws -> MockResponse {
            let data = try encoder.encode(object)
            return MockResponse(
                data: data,
                statusCode: statusCode,
                headers: ["Content-Type": "application/json"]
            )
        }

        /// Creates a mock response from a JSON string
        static func jsonString(
            _ json: String,
            statusCode: Int = 200
        ) -> MockResponse {
            MockResponse(
                data: Data(json.utf8),
                statusCode: statusCode,
                headers: ["Content-Type": "application/json"]
            )
        }
    }

    /// Creates a new mock network service
    /// - Parameters:
    ///   - baseURL: The base URL (optional, not really used)
    ///   - delay: Simulated network delay in seconds (default: 0.1)
    ///   - shouldError: Whether to always throw errors (default: false)
    ///   - errorToThrow: The error to throw when shouldError is true
    ///   - mockResponses: Initial mock responses keyed by path
    init(
        baseURL: URL? = nil,
        delay: TimeInterval = 0.1,
        shouldError: Bool = false,
        errorToThrow: NetworkError = .unknown("Mock error"),
        mockResponses: [String: MockResponse] = [:]
    ) {
        self.baseURL = baseURL
        self.delay = delay
        self.shouldError = shouldError
        self.errorToThrow = errorToThrow
        self.mockResponses = mockResponses
    }

    /// Registers a mock response for a specific path
    /// - Parameters:
    ///   - path: The path to mock
    ///   - response: The mock response to return
    func register(path: String, response: MockResponse) {
        mockResponses[path] = response
    }

    /// Registers a mock response for a specific path using an Encodable object
    /// - Parameters:
    ///   - path: The path to mock
    ///   - object: The object to encode as the response
    ///   - statusCode: The HTTP status code
    func register<T: Encodable>(path: String, object: T, statusCode: Int = 200) throws {
        let response = try MockResponse.json(object, statusCode: statusCode)
        mockResponses[path] = response
    }

    /// Clears all recorded requests
    func clearRecordedRequests() {
        recordedRequests = []
    }

    /// Clears all mock responses
    func clearMockResponses() {
        mockResponses = [:]
    }

    func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        // Record the request
        recordedRequests.append(request)

        // Simulate network delay
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }

        // Check if we should throw an error
        if shouldError {
            throw errorToThrow
        }

        // Look up mock response
        if let mockResponse = mockResponses[request.path] {
            // Check for error status codes
            if let error = NetworkError.fromStatusCode(mockResponse.statusCode, data: mockResponse.data) {
                throw error
            }

            return NetworkResponse(
                data: mockResponse.data,
                statusCode: mockResponse.statusCode,
                headers: mockResponse.headers
            )
        }

        // Default empty success response if no mock is registered
        return NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [:]
        )
    }
}
