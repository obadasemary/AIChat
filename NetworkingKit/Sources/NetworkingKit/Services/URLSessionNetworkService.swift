import Foundation

/// Production implementation of NetworkServiceProtocol using URLSession.
///
/// `@unchecked Sendable`: All stored properties are immutable `let` constants after
/// initialisation, so no mutable state is shared across isolation domains. The
/// `@unchecked` qualifier is required because `URLSession` is an Objective-C
/// `final class` whose `Sendable` conformance cannot be inferred by the Swift
/// compiler from its declaration alone, even though it has been concurrency-safe
/// since Swift 5.7 / iOS 16.
public final class URLSessionNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    public let baseURL: URL?

    private let session: URLSession
    private let defaultHeaders: [String: String]
    private let requestInterceptors: [RequestInterceptor]
    private let responseInterceptors: [ResponseInterceptor]

    /// Creates a new URLSession network service
    public init(
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

    /// Convenience initializer with URLSessionConfiguration
    public convenience init(
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

    /// Invalidates the session to release delegate and callback references.
    /// - Note: Only has an effect when a custom `URLSessionConfiguration` was provided
    ///   via the `configuration:` initialiser. Calling `finishTasksAndInvalidate()` on
    ///   `URLSession.shared` is a no-op, so passing the shared session is safe.
    deinit {
        session.finishTasksAndInvalidate()
    }

    public func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        var urlRequest = try buildURLRequest(from: request)

        for interceptor in requestInterceptors {
            urlRequest = try await interceptor.intercept(urlRequest)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw NetworkError.fromURLError(urlError)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }

        guard var networkResponse = NetworkResponse(data: data, response: response, request: urlRequest) else {
            throw NetworkError.invalidResponse
        }

        for interceptor in responseInterceptors {
            networkResponse = try await interceptor.intercept(networkResponse)
        }

        if let error = NetworkError.fromStatusCode(networkResponse.statusCode, data: data) {
            throw error
        }

        return networkResponse
    }

    // MARK: - Private

    private func buildURLRequest(from request: NetworkRequest) throws -> URLRequest {
        let url = try buildURL(from: request)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = request.cachePolicy

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

    private func buildURL(from request: NetworkRequest) throws -> URL {
        if let absoluteURL = URL(string: request.path), absoluteURL.scheme != nil {
            return try appendQueryParameters(to: absoluteURL, parameters: request.queryParameters)
        }

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
