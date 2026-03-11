// URLSessionNetworkService.swift
// NetworkKit

import Foundation

/// Production `NetworkServiceProtocol` implementation backed by `URLSession`.
///
/// ### Swift Concurrency design
/// All stored properties are `let` (immutable after init), and every type stored
/// here is `Sendable`.  That makes `URLSessionNetworkService` automatically
/// `Sendable` — **no `@unchecked Sendable` needed**.
///
/// `URLSession` is `@unchecked Sendable` in the SDK; it is internally
/// thread-safe and designed for concurrent use.  Interceptors are `Sendable`
/// value types (`struct`), so storing them as `let` arrays is safe.
///
/// ### Interceptor pipeline
/// Request interceptors are applied in registration order before the request is
/// sent; response interceptors are applied in registration order after the
/// response arrives.
public final class URLSessionNetworkService: NetworkServiceProtocol, Sendable {

    // MARK: - Properties

    public let baseURL: URL?

    private let session: URLSession
    private let defaultHeaders: [String: String]
    private let requestInterceptors: [any RequestInterceptor]
    private let responseInterceptors: [any ResponseInterceptor]

    // MARK: - Initialisers

    public init(
        baseURL: URL? = nil,
        session: URLSession = .shared,
        defaultHeaders: [String: String] = [:],
        requestInterceptors: [any RequestInterceptor] = [],
        responseInterceptors: [any ResponseInterceptor] = []
    ) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
    }

    /// Convenience initialiser that creates a dedicated `URLSession` from the
    /// provided `URLSessionConfiguration`.
    public convenience init(
        baseURL: URL? = nil,
        configuration: URLSessionConfiguration,
        defaultHeaders: [String: String] = [:],
        requestInterceptors: [any RequestInterceptor] = [],
        responseInterceptors: [any ResponseInterceptor] = []
    ) {
        self.init(
            baseURL: baseURL,
            session: URLSession(configuration: configuration),
            defaultHeaders: defaultHeaders,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )
    }

    // MARK: - NetworkServiceProtocol

    public func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        // Build the base URLRequest from the NetworkRequest value.
        var urlRequest = try buildURLRequest(from: request)

        // Apply request interceptors in order (e.g. auth headers, logging).
        for interceptor in requestInterceptors {
            urlRequest = try await interceptor.intercept(urlRequest)
        }

        // Perform the actual network I/O via URLSession.
        let (data, urlResponse): (Data, URLResponse)
        do {
            (data, urlResponse) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw NetworkError.fromURLError(urlError)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }

        // Wrap the raw URLResponse in our typed NetworkResponse.
        guard var networkResponse = NetworkResponse(data: data, response: urlResponse, request: urlRequest) else {
            throw NetworkError.invalidResponse
        }

        // Apply response interceptors in order (e.g. logging).
        for interceptor in responseInterceptors {
            networkResponse = try await interceptor.intercept(networkResponse)
        }

        // Surface any HTTP-layer errors (4xx / 5xx).
        if let error = NetworkError.fromStatusCode(networkResponse.statusCode, data: data) {
            throw error
        }

        return networkResponse
    }

    // MARK: - URL construction

    private func buildURLRequest(from request: NetworkRequest) throws -> URLRequest {
        let url = try resolvedURL(for: request)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = request.cachePolicy

        // Merge default headers first, then request-specific headers (which take precedence).
        for (key, value) in defaultHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        urlRequest.httpBody = request.body
        return urlRequest
    }

    private func resolvedURL(for request: NetworkRequest) throws -> URL {
        // Treat non-empty paths that already carry a scheme as absolute URLs.
        if let absolute = URL(string: request.path), absolute.scheme != nil {
            return try appendingQueryParameters(request.queryParameters, to: absolute)
        }

        guard let base = baseURL else { throw NetworkError.invalidURL }

        let url: URL = request.path.isEmpty
            ? base
            : base.appendingPathComponent(request.path)

        return try appendingQueryParameters(request.queryParameters, to: url)
    }

    private func appendingQueryParameters(_ parameters: [String: String]?, to url: URL) throws -> URL {
        guard let parameters, !parameters.isEmpty else { return url }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        var items = components.queryItems ?? []
        for (key, value) in parameters.sorted(by: { $0.key < $1.key }) {
            items.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = items

        guard let final = components.url else { throw NetworkError.invalidURL }
        return final
    }
}
