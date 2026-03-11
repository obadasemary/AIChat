import Foundation

/// Interceptor that logs requests and responses
public final class LoggingInterceptor: RequestInterceptor, ResponseInterceptor, @unchecked Sendable {
    /// Log level for network logging
    public enum LogLevel: Int, Sendable {
        case none = 0
        case basic = 1
        case headers = 2
        case body = 3
    }

    private let logLevel: LogLevel
    private let logToConsole: Bool
    private let customLogger: (@Sendable (String) -> Void)?

    /// Creates a new logging interceptor
    public init(
        logLevel: LogLevel = .basic,
        logToConsole: Bool = false,
        customLogger: (@Sendable (String) -> Void)? = nil
    ) {
        self.logLevel = logLevel
        self.logToConsole = logToConsole
        self.customLogger = customLogger
    }

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard logLevel != .none else { return request }

        var logMessage = "[Network Request]"

        if let method = request.httpMethod, let url = request.url {
            logMessage += "\n  \(method) \(url.absoluteString)"
        }

        if logLevel.rawValue >= LogLevel.headers.rawValue,
           let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logMessage += "\n  Headers:"
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                let maskedValue = sensitiveHeaders.contains(key.lowercased()) ? "***" : value
                logMessage += "\n    \(key): \(maskedValue)"
            }
        }

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

    public func intercept(_ response: NetworkResponse) async throws -> NetworkResponse {
        guard logLevel != .none else { return response }

        var logMessage = "[Network Response]"

        if let url = response.request?.url {
            logMessage += "\n  URL: \(url.absoluteString)"
        }
        logMessage += "\n  Status: \(response.statusCode)"

        if logLevel.rawValue >= LogLevel.headers.rawValue, !response.headers.isEmpty {
            logMessage += "\n  Headers:"
            for (key, value) in response.headers.sorted(by: { $0.key < $1.key }) {
                logMessage += "\n    \(key): \(value)"
            }
        }

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
