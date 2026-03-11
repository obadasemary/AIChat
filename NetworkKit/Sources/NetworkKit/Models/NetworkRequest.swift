// NetworkRequest.swift
// NetworkKit

import Foundation

/// Encapsulates everything needed to describe a single HTTP request.
///
/// `NetworkRequest` is a pure value type – all stored properties are immutable,
/// so it is automatically `Sendable` and safe to pass across concurrency domains.
public struct NetworkRequest: Sendable {

    // MARK: - Properties

    /// The URL path – either a relative path appended to the service's `baseURL`,
    /// or an absolute URL string used as-is.
    public let path: String

    /// HTTP verb for this request.
    public let method: HTTPMethod

    /// Query parameters appended to the URL as a query string.
    public let queryParameters: [String: String]?

    /// Additional HTTP headers merged on top of any default headers.
    public let headers: [String: String]?

    /// The raw body data sent with the request.
    public let body: Data?

    /// Timeout for this request in seconds.
    public let timeoutInterval: TimeInterval

    /// Caching behaviour for this request.
    public let cachePolicy: URLRequest.CachePolicy

    // MARK: - Initialiser

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
}

// MARK: - Convenience Factories

extension NetworkRequest {

    /// Creates a GET request.
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

    /// Creates a POST request whose body is the JSON-encoded `body` value.
    public static func post<T: Encodable>(
        _ path: String,
        body: T,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        timeoutInterval: TimeInterval = 30
    ) throws -> NetworkRequest {
        let data = try encoder.encode(body)
        var merged = headers ?? [:]
        merged["Content-Type"] = "application/json"
        return NetworkRequest(path: path, method: .post, headers: merged, body: data, timeoutInterval: timeoutInterval)
    }

    /// Creates a POST request with raw body data.
    public static func post(
        _ path: String,
        data: Data,
        contentType: String = "application/json",
        headers: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30
    ) -> NetworkRequest {
        var merged = headers ?? [:]
        merged["Content-Type"] = contentType
        return NetworkRequest(path: path, method: .post, headers: merged, body: data, timeoutInterval: timeoutInterval)
    }

    /// Creates a PUT request whose body is the JSON-encoded `body` value.
    public static func put<T: Encodable>(
        _ path: String,
        body: T,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        timeoutInterval: TimeInterval = 30
    ) throws -> NetworkRequest {
        let data = try encoder.encode(body)
        var merged = headers ?? [:]
        merged["Content-Type"] = "application/json"
        return NetworkRequest(path: path, method: .put, headers: merged, body: data, timeoutInterval: timeoutInterval)
    }

    /// Creates a PATCH request whose body is the JSON-encoded `body` value.
    public static func patch<T: Encodable>(
        _ path: String,
        body: T,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        timeoutInterval: TimeInterval = 30
    ) throws -> NetworkRequest {
        let data = try encoder.encode(body)
        var merged = headers ?? [:]
        merged["Content-Type"] = "application/json"
        return NetworkRequest(path: path, method: .patch, headers: merged, body: data, timeoutInterval: timeoutInterval)
    }

    /// Creates a DELETE request.
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
