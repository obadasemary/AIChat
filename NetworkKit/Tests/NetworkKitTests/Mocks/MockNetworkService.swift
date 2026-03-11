// MockNetworkService.swift
// NetworkKitTests

import Foundation
@testable import NetworkKit

// MARK: - MockNetworkService

/// An `actor`-based test double for `NetworkServiceProtocol`.
///
/// Using an `actor` gives us isolated, mutable state without locks or
/// `@unchecked Sendable` — the Swift 6 compiler verifies all access is safe.
///
/// ### Usage
/// ```swift
/// let mock = MockNetworkService()
/// await mock.register(path: "/users", response: .jsonString("{\"id\": 1}"))
///
/// let client = NetworkClient(service: mock)
/// let response = try await client.execute(.get("/users"))
/// ```
actor MockNetworkService: NetworkServiceProtocol {

    // MARK: - NetworkServiceProtocol

    nonisolated let baseURL: URL?

    // MARK: - Configuration

    private let simulatedDelay: TimeInterval
    private let shouldAlwaysError: Bool
    private let errorToThrow: NetworkError

    // MARK: - State

    private var mockResponses: [String: MockResponse] = [:]
    private(set) var recordedRequests: [NetworkRequest] = []

    // MARK: - MockResponse

    struct MockResponse: Sendable {
        let data: Data
        let statusCode: Int
        let headers: [String: String]

        init(data: Data, statusCode: Int = 200, headers: [String: String] = [:]) {
            self.data = data
            self.statusCode = statusCode
            self.headers = headers
        }

        static func json<T: Encodable>(
            _ object: T,
            statusCode: Int = 200,
            encoder: JSONEncoder = JSONEncoder()
        ) throws -> MockResponse {
            MockResponse(
                data: try encoder.encode(object),
                statusCode: statusCode,
                headers: ["Content-Type": "application/json"]
            )
        }

        static func jsonString(_ json: String, statusCode: Int = 200) -> MockResponse {
            MockResponse(
                data: Data(json.utf8),
                statusCode: statusCode,
                headers: ["Content-Type": "application/json"]
            )
        }
    }

    // MARK: - Initialiser

    init(
        baseURL: URL? = nil,
        simulatedDelay: TimeInterval = 0,
        shouldAlwaysError: Bool = false,
        errorToThrow: NetworkError = .unknown("Mock error")
    ) {
        self.baseURL = baseURL
        self.simulatedDelay = simulatedDelay
        self.shouldAlwaysError = shouldAlwaysError
        self.errorToThrow = errorToThrow
    }

    // MARK: - Registration helpers

    func register(path: String, response: MockResponse) {
        mockResponses[path] = response
    }

    func register<T: Encodable>(path: String, object: T, statusCode: Int = 200) throws {
        mockResponses[path] = try MockResponse.json(object, statusCode: statusCode)
    }

    func clearRecordedRequests() { recordedRequests.removeAll() }
    func clearMockResponses()    { mockResponses.removeAll() }

    // MARK: - NetworkServiceProtocol

    func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        recordedRequests.append(request)

        if simulatedDelay > 0 {
            try await Task.sleep(for: .seconds(simulatedDelay))
        }

        if shouldAlwaysError { throw errorToThrow }

        if let mock = mockResponses[request.path] {
            if let error = NetworkError.fromStatusCode(mock.statusCode, data: mock.data) {
                throw error
            }
            return NetworkResponse(data: mock.data, statusCode: mock.statusCode, headers: mock.headers)
        }

        // No registered response – return empty 200.
        return NetworkResponse(data: Data(), statusCode: 200)
    }
}
