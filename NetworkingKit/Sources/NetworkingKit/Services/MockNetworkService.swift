import Foundation

/// Mock implementation of NetworkServiceProtocol for testing
public actor MockNetworkService: NetworkServiceProtocol {
    public let baseURL: URL?

    private let delay: TimeInterval
    private let shouldError: Bool
    private let errorToThrow: NetworkError
    private var mockResponses: [String: MockResponse]

    public private(set) var recordedRequests: [NetworkRequest] = []

    /// A mock response configuration
    public struct MockResponse: Sendable {
        public let data: Data
        public let statusCode: Int
        public let headers: [String: String]

        public init(
            data: Data,
            statusCode: Int = 200,
            headers: [String: String] = [:]
        ) {
            self.data = data
            self.statusCode = statusCode
            self.headers = headers
        }

        public static func json<T: Encodable>(
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

        public static func jsonString(
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
    public init(
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

    public func register(path: String, response: MockResponse) {
        mockResponses[path] = response
    }

    public func register<T: Encodable>(path: String, object: T, statusCode: Int = 200) throws {
        let response = try MockResponse.json(object, statusCode: statusCode)
        mockResponses[path] = response
    }

    public func clearRecordedRequests() {
        recordedRequests = []
    }

    public func clearMockResponses() {
        mockResponses = [:]
    }

    public func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        recordedRequests.append(request)

        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }

        if shouldError {
            throw errorToThrow
        }

        if let mockResponse = mockResponses[request.path] {
            if let error = NetworkError.fromStatusCode(mockResponse.statusCode, data: mockResponse.data) {
                throw error
            }

            return NetworkResponse(
                data: mockResponse.data,
                statusCode: mockResponse.statusCode,
                headers: mockResponse.headers
            )
        }

        return NetworkResponse(
            data: Data(),
            statusCode: 200,
            headers: [:]
        )
    }
}
