//
//  NetworkRequest.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// A network request configuration
struct NetworkRequest: Sendable {
    /// The URL path (relative to base URL or absolute)
    let path: String

    /// The HTTP method
    let method: HTTPMethod

    /// Query parameters to be appended to the URL
    let queryParameters: [String: String]?

    /// HTTP headers
    let headers: [String: String]?

    /// Request body data
    let body: Data?

    /// Request timeout interval in seconds
    let timeoutInterval: TimeInterval

    /// Cache policy for the request
    let cachePolicy: URLRequest.CachePolicy

    /// Creates a new network request
    /// - Parameters:
    ///   - path: The URL path
    ///   - method: The HTTP method (default: .get)
    ///   - queryParameters: Query parameters (default: nil)
    ///   - headers: HTTP headers (default: nil)
    ///   - body: Request body data (default: nil)
    ///   - timeoutInterval: Timeout in seconds (default: 30)
    ///   - cachePolicy: Cache policy (default: .useProtocolCachePolicy)
    init(
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
    static func get(
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
    static func post<T: Encodable>(
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
    static func post(
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
    static func put<T: Encodable>(
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
    static func patch<T: Encodable>(
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
    static func delete(
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
