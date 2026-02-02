//
//  LoggingInterceptor.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Interceptor that logs requests and responses
final class LoggingInterceptor: RequestInterceptor, ResponseInterceptor, @unchecked Sendable {
    /// Log level for network logging
    enum LogLevel: Int, Sendable {
        /// No logging
        case none = 0
        /// Log only basic info (URL, method, status code)
        case basic = 1
        /// Log headers in addition to basic info
        case headers = 2
        /// Log full body in addition to headers
        case body = 3
    }

    /// The current log level
    private let logLevel: LogLevel

    /// Whether to log to console
    private let logToConsole: Bool

    /// Optional custom logger
    private let customLogger: (@Sendable (String) -> Void)?

    /// Creates a new logging interceptor
    /// - Parameters:
    ///   - logLevel: The log level (default: .basic)
    ///   - logToConsole: Whether to log to console (default: true)
    ///   - customLogger: Optional custom logger closure
    init(
        logLevel: LogLevel = .basic,
        logToConsole: Bool = true,
        customLogger: (@Sendable (String) -> Void)? = nil
    ) {
        self.logLevel = logLevel
        self.logToConsole = logToConsole
        self.customLogger = customLogger
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard logLevel != .none else { return request }

        var logMessage = "[Network Request]"

        // Basic info
        if let method = request.httpMethod, let url = request.url {
            logMessage += "\n  \(method) \(url.absoluteString)"
        }

        // Headers
        if logLevel.rawValue >= LogLevel.headers.rawValue,
           let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logMessage += "\n  Headers:"
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                // Mask sensitive headers
                let maskedValue = sensitiveHeaders.contains(key.lowercased()) ? "***" : value
                logMessage += "\n    \(key): \(maskedValue)"
            }
        }

        // Body
        if logLevel.rawValue >= LogLevel.body.rawValue,
           let body = request.httpBody {
            logMessage += "\n  Body:"
            if let bodyString = String(data: body, encoding: .utf8) {
                let truncated = bodyString.count > 1000 ? String(bodyString.prefix(1000)) + "..." : bodyString
                logMessage += "\n    \(truncated)"
            } else {
                logMessage += "\n    <binary data: \(body.count) bytes>"
            }
        }

        log(logMessage)
        return request
    }

    func intercept(_ response: NetworkResponse) async throws -> NetworkResponse {
        guard logLevel != .none else { return response }

        var logMessage = "[Network Response]"

        // Basic info
        if let url = response.request?.url {
            logMessage += "\n  URL: \(url.absoluteString)"
        }
        logMessage += "\n  Status: \(response.statusCode)"

        // Headers
        if logLevel.rawValue >= LogLevel.headers.rawValue, !response.headers.isEmpty {
            logMessage += "\n  Headers:"
            for (key, value) in response.headers.sorted(by: { $0.key < $1.key }) {
                logMessage += "\n    \(key): \(value)"
            }
        }

        // Body
        if logLevel.rawValue >= LogLevel.body.rawValue {
            logMessage += "\n  Body:"
            if let bodyString = response.string() {
                let truncated = bodyString.count > 1000 ? String(bodyString.prefix(1000)) + "..." : bodyString
                logMessage += "\n    \(truncated)"
            } else {
                logMessage += "\n    <binary data: \(response.data.count) bytes>"
            }
        }

        log(logMessage)
        return response
    }

    // MARK: - Private

    private let sensitiveHeaders: Set<String> = [
        "authorization",
        "x-api-key",
        "api-key",
        "x-auth-token",
        "cookie",
        "set-cookie"
    ]

    private func log(_ message: String) {
        if logToConsole {
            print(message)
        }
        customLogger?(message)
    }
}
