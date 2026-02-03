//
//  URLSessionNetworkService.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Production implementation of NetworkServiceProtocol using URLSession
final class URLSessionNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    /// The base URL for all requests
    let baseURL: URL?

    /// The URL session to use for requests
    private let session: URLSession

    /// Default headers to include in all requests
    private let defaultHeaders: [String: String]

    /// Request interceptors to apply before sending
    private let requestInterceptors: [RequestInterceptor]

    /// Response interceptors to apply after receiving
    private let responseInterceptors: [ResponseInterceptor]

    /// Creates a new URLSession network service
    /// - Parameters:
    ///   - baseURL: The base URL for all requests (optional)
    ///   - session: The URL session to use (default: .shared)
    ///   - defaultHeaders: Default headers for all requests
    ///   - requestInterceptors: Interceptors to apply to requests
    ///   - responseInterceptors: Interceptors to apply to responses
    init(
        baseURL: URL? = nil,
        session: URLSession = .shared,
        defaultHeaders: [String: String] = [:],
        requestInterceptors: [RequestInterceptor] = [],
        responseInterceptors: [ResponseInterceptor] = []
    ) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
    }

    /// Convenience initializer with configuration
    /// - Parameters:
    ///   - baseURL: The base URL for all requests
    ///   - configuration: URL session configuration
    ///   - defaultHeaders: Default headers for all requests
    ///   - requestInterceptors: Interceptors to apply to requests
    ///   - responseInterceptors: Interceptors to apply to responses
    convenience init(
        baseURL: URL?,
        configuration: URLSessionConfiguration,
        defaultHeaders: [String: String] = [:],
        requestInterceptors: [RequestInterceptor] = [],
        responseInterceptors: [ResponseInterceptor] = []
    ) {
        let session = URLSession(configuration: configuration)
        self.init(
            baseURL: baseURL,
            session: session,
            defaultHeaders: defaultHeaders,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )
    }
    
    deinit {
        session.finishTasksAndInvalidate()
    }

    func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        // Build the URL request
        var urlRequest = try buildURLRequest(from: request)

        // Apply request interceptors
        for interceptor in requestInterceptors {
            urlRequest = try await interceptor.intercept(urlRequest)
        }

        // Execute the request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw NetworkError.fromURLError(urlError)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }

        // Create network response
        guard var networkResponse = NetworkResponse(data: data, response: response, request: urlRequest) else {
            throw NetworkError.invalidResponse
        }

        // Apply response interceptors
        for interceptor in responseInterceptors {
            networkResponse = try await interceptor.intercept(networkResponse)
        }

        // Check for HTTP errors
        if let error = NetworkError.fromStatusCode(networkResponse.statusCode, data: data) {
            throw error
        }

        return networkResponse
    }

    // MARK: - Private Methods

    private func buildURLRequest(from request: NetworkRequest) throws -> URLRequest {
        // Build the URL
        let url = try buildURL(from: request)

        // Create the request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = request.cachePolicy

        // Add default headers
        for (key, value) in defaultHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Add request-specific headers
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Add body
        urlRequest.httpBody = request.body

        return urlRequest
    }

    private func buildURL(from request: NetworkRequest) throws -> URL {
        // Check if path is already an absolute URL
        if let absoluteURL = URL(string: request.path), absoluteURL.scheme != nil {
            return try appendQueryParameters(to: absoluteURL, parameters: request.queryParameters)
        }

        // Build URL from base URL and path
        guard let baseURL = baseURL else {
            throw NetworkError.invalidURL
        }

        var url: URL
        if request.path.isEmpty {
            url = baseURL
        } else {
            url = baseURL.appendingPathComponent(request.path)
        }

        return try appendQueryParameters(to: url, parameters: request.queryParameters)
    }

    private func appendQueryParameters(to url: URL, parameters: [String: String]?) throws -> URL {
        guard let parameters = parameters, !parameters.isEmpty else {
            return url
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        var queryItems = components.queryItems ?? []
        for (key, value) in parameters.sorted(by: { $0.key < $1.key }) {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems

        guard let finalURL = components.url else {
            throw NetworkError.invalidURL
        }

        return finalURL
    }
}
