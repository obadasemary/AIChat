// NetworkResponse.swift
// NetworkKit

import Foundation

/// Represents the result of an HTTP response – the status code, headers, and raw body.
///
/// All stored properties are immutable value types, making `NetworkResponse`
/// automatically `Sendable` and safe to pass across concurrency domains.
public struct NetworkResponse: Sendable {

    // MARK: - Properties

    /// The raw response body.
    public let data: Data

    /// HTTP status code returned by the server.
    public let statusCode: Int

    /// Response headers keyed by their (lowercased) field name.
    public let headers: [String: String]

    /// The original `URLRequest` that produced this response, if available.
    public let request: URLRequest?

    /// `true` when `statusCode` falls in the 200–299 range.
    public var isSuccess: Bool {
        (200...299).contains(statusCode)
    }

    // MARK: - Initialisers

    public init(
        data: Data,
        statusCode: Int,
        headers: [String: String] = [:],
        request: URLRequest? = nil
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.request = request
    }

    /// Convenience initialiser that extracts metadata from a raw `URLResponse`.
    ///
    /// Returns `nil` when `response` is not an `HTTPURLResponse`.
    public init?(data: Data, response: URLResponse?, request: URLRequest? = nil) {
        guard let http = response as? HTTPURLResponse else { return nil }

        self.data = data
        self.statusCode = http.statusCode
        self.request = request

        var headers: [String: String] = [:]
        for (key, value) in http.allHeaderFields {
            if let k = key as? String, let v = value as? String {
                headers[k] = v
            }
        }
        self.headers = headers
    }

    // MARK: - Decoding

    /// Decodes the response body to the requested `Decodable` type.
    ///
    /// - Throws: `NetworkError.decodingFailed` when decoding fails.
    public func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error.localizedDescription)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    /// Interprets the response body as a UTF-8 string.
    public func string(encoding: String.Encoding = .utf8) -> String? {
        String(data: data, encoding: encoding)
    }
}
