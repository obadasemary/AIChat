// LoggingInterceptor.swift
// NetworkKit

import Foundation

/// A `RequestInterceptor` and `ResponseInterceptor` that logs network traffic.
///
/// `LoggingInterceptor` is a value type (`struct`) with all immutable stored
/// properties — no `@unchecked Sendable` required.
///
/// Sensitive header values (Authorization, cookies, etc.) are automatically
/// masked so credentials are never written to logs.
///
/// ## Usage
/// ```swift
/// let logger = LoggingInterceptor(logLevel: .headers)
/// let service = URLSessionNetworkService(
///     requestInterceptors:  [logger],
///     responseInterceptors: [logger]
/// )
/// ```
public struct LoggingInterceptor: RequestInterceptor, ResponseInterceptor {

    // MARK: - Log level

    /// Controls how much detail is included in each log entry.
    public enum LogLevel: Int, Sendable, Comparable {
        /// No output.
        case none    = 0
        /// Method + URL / status code only.
        case basic   = 1
        /// `basic` + all HTTP headers (sensitive values are masked).
        case headers = 2
        /// `headers` + full body (truncated at 1 000 characters).
        case body    = 3

        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    // MARK: - Stored properties

    private let logLevel: LogLevel
    private let logToConsole: Bool
    /// Called in addition to (or instead of) `print` when provided.
    private let customLogger: (@Sendable (String) -> Void)?

    // MARK: - Initialiser

    public init(
        logLevel: LogLevel = .basic,
        logToConsole: Bool = true,
        customLogger: (@Sendable (String) -> Void)? = nil
    ) {
        self.logLevel = logLevel
        self.logToConsole = logToConsole
        self.customLogger = customLogger
    }

    // MARK: - RequestInterceptor

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard logLevel != .none else { return request }

        var msg = "[NetworkKit ↑ Request]"

        if let method = request.httpMethod, let url = request.url {
            msg += "\n  \(method) \(url.absoluteString)"
        }

        if logLevel >= .headers, let fields = request.allHTTPHeaderFields, !fields.isEmpty {
            msg += "\n  Headers:"
            for (key, value) in fields.sorted(by: { $0.key < $1.key }) {
                msg += "\n    \(key): \(masked(header: key, value: value))"
            }
        }

        if logLevel >= .body, let body = request.httpBody {
            msg += "\n  Body:\n    \(truncated(body))"
        }

        emit(msg)
        return request
    }

    // MARK: - ResponseInterceptor

    public func intercept(_ response: NetworkResponse) async throws -> NetworkResponse {
        guard logLevel != .none else { return response }

        var msg = "[NetworkKit ↓ Response]"
        msg += "\n  Status: \(response.statusCode)"

        if let url = response.request?.url {
            msg += "\n  URL: \(url.absoluteString)"
        }

        if logLevel >= .headers, !response.headers.isEmpty {
            msg += "\n  Headers:"
            for (key, value) in response.headers.sorted(by: { $0.key < $1.key }) {
                msg += "\n    \(key): \(value)"
            }
        }

        if logLevel >= .body {
            msg += "\n  Body:\n    \(truncated(response.data))"
        }

        emit(msg)
        return response
    }

    // MARK: - Private helpers

    private static let sensitiveHeaders: Set<String> = [
        "authorization", "x-api-key", "api-key", "x-auth-token", "cookie", "set-cookie"
    ]

    private func masked(header: String, value: String) -> String {
        LoggingInterceptor.sensitiveHeaders.contains(header.lowercased()) ? "***" : value
    }

    private func truncated(_ data: Data) -> String {
        guard let text = String(data: data, encoding: .utf8) else {
            return "<binary data: \(data.count) bytes>"
        }
        return text.count > 1_000 ? String(text.prefix(1_000)) + "…" : text
    }

    private func emit(_ message: String) {
        if logToConsole { print(message) }
        customLogger?(message)
    }
}
