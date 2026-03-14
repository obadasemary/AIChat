import Foundation

/// A network request configuration
public struct NetworkRequest: Sendable {
    /// The URL path (relative to base URL or absolute)
    public let path: String

    /// The HTTP method
    public let method: HTTPMethod

    /// Query parameters to be appended to the URL
    public let queryParameters: [String: String]?

    /// HTTP headers
    public let headers: [String: String]?

    /// Request body data
    public let body: Data?

    /// Request timeout interval in seconds
    public let timeoutInterval: TimeInterval

    /// Cache policy for the request
    public let cachePolicy: URLRequest.CachePolicy

    /// Creates a new network request
    public init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headers = headers
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
    }

    /// Creates a GET request
    public static func get(
        _ path: String,
        queryParameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30
    ) -> NetworkRequest {
        NetworkRequest(
            path: path,
            method: .get,
            queryParameters: queryParameters,
            headers: headers,
            timeoutInterval: timeoutInterval
        )
    }

    /// Creates a POST request with JSON body
    public static func post<T: Encodable>(
        _ path: String,
        body: T,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        timeoutInterval: TimeInterval = 30
    ) throws -> NetworkRequest {
        let data = try encoder.encode(body)
        var allHeaders = headers ?? [:]
        allHeaders["Content-Type"] = "application/json"

        return NetworkRequest(
            path: path,
            method: .post,
            headers: allHeaders,
            body: data,
            timeoutInterval: timeoutInterval
        )
    }

    /// Creates a POST request with raw data body
    public static func post(
        _ path: String,
        data: Data,
        contentType: String = "application/json",
        headers: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30
    ) -> NetworkRequest {
        var allHeaders = headers ?? [:]
        allHeaders["Content-Type"] = contentType

        return NetworkRequest(
            path: path,
            method: .post,
            headers: allHeaders,
            body: data,
            timeoutInterval: timeoutInterval
        )
    }

    /// Creates a PUT request with JSON body
    public static func put<T: Encodable>(
        _ path: String,
        body: T,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        timeoutInterval: TimeInterval = 30
    ) throws -> NetworkRequest {
        let data = try encoder.encode(body)
        var allHeaders = headers ?? [:]
        allHeaders["Content-Type"] = "application/json"

        return NetworkRequest(
            path: path,
            method: .put,
            headers: allHeaders,
            body: data,
            timeoutInterval: timeoutInterval
        )
    }

    /// Creates a PATCH request with JSON body
    public static func patch<T: Encodable>(
        _ path: String,
        body: T,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        timeoutInterval: TimeInterval = 30
    ) throws -> NetworkRequest {
        let data = try encoder.encode(body)
        var allHeaders = headers ?? [:]
        allHeaders["Content-Type"] = "application/json"

        return NetworkRequest(
            path: path,
            method: .patch,
            headers: allHeaders,
            body: data,
            timeoutInterval: timeoutInterval
        )
    }

    /// Creates a DELETE request
    public static func delete(
        _ path: String,
        queryParameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30
    ) -> NetworkRequest {
        NetworkRequest(
            path: path,
            method: .delete,
            queryParameters: queryParameters,
            headers: headers,
            timeoutInterval: timeoutInterval
        )
    }
}
