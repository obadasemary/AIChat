import Foundation

/// A network response containing data and metadata
public struct NetworkResponse: Sendable {
    /// The response data
    public let data: Data

    /// The HTTP status code
    public let statusCode: Int

    /// The response headers
    public let headers: [String: String]

    /// The original URL request
    public let request: URLRequest?

    /// Whether the response indicates success (2xx status code)
    public var isSuccess: Bool {
        (200...299).contains(statusCode)
    }

    /// Creates a new network response
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

    /// Creates a NetworkResponse from URLResponse
    public init?(data: Data, response: URLResponse?, request: URLRequest? = nil) {
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
    public func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingFailed(decodingError.localizedDescription)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    /// Returns the response data as a string
    public func string(encoding: String.Encoding = .utf8) -> String? {
        String(data: data, encoding: encoding)
    }
}
