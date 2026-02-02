//
//  NetworkResponse.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// A network response containing data and metadata
struct NetworkResponse: Sendable {
    /// The response data
    let data: Data

    /// The HTTP status code
    let statusCode: Int

    /// The response headers
    let headers: [String: String]

    /// The original URL request
    let request: URLRequest?

    /// Whether the response indicates success (2xx status code)
    var isSuccess: Bool {
        (200...299).contains(statusCode)
    }

    /// Creates a new network response
    /// - Parameters:
    ///   - data: The response data
    ///   - statusCode: The HTTP status code
    ///   - headers: The response headers
    ///   - request: The original URL request
    init(
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

    /// Creates a NetworkResponse from URLResponse
    /// - Parameters:
    ///   - data: The response data
    ///   - response: The URL response
    ///   - request: The original URL request
    init?(data: Data, response: URLResponse?, request: URLRequest? = nil) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }

        self.data = data
        self.statusCode = httpResponse.statusCode

        var headers: [String: String] = [:]
        for (key, value) in httpResponse.allHeaderFields {
            if let keyString = key as? String, let valueString = value as? String {
                headers[keyString] = valueString
            }
        }
        self.headers = headers
        self.request = request
    }

    /// Decodes the response data to the specified type
    /// - Parameters:
    ///   - type: The type to decode to
    ///   - decoder: The JSON decoder to use
    /// - Returns: The decoded object
    func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingFailed(decodingError.localizedDescription)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    /// Returns the response data as a string
    /// - Parameter encoding: The string encoding to use
    /// - Returns: The response as a string, or nil if conversion fails
    func string(encoding: String.Encoding = .utf8) -> String? {
        String(data: data, encoding: encoding)
    }
}
