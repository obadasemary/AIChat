import Foundation

/// Configuration for retry behavior
public struct RetryConfiguration: Sendable {
    public let maxRetries: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let exponentialBackoff: Bool
    public let retryableStatusCodes: Set<Int>

    /// Default retry configuration
    public static let `default` = RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        exponentialBackoff: true,
        retryableStatusCodes: [408, 429, 500, 502, 503, 504]
    )

    public init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        exponentialBackoff: Bool = true,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.exponentialBackoff = exponentialBackoff
        self.retryableStatusCodes = retryableStatusCodes
    }

    /// Calculates the delay for a given retry attempt
    public func delay(for attempt: Int) -> TimeInterval {
        if exponentialBackoff {
            let delay = baseDelay * pow(2.0, Double(attempt))
            return min(delay, maxDelay)
        }
        return baseDelay
    }
}

/// A helper that provides retry functionality for network requests
public struct RetryHandler: Sendable {
    private let configuration: RetryConfiguration

    public init(configuration: RetryConfiguration = .default) {
        self.configuration = configuration
    }

    /// Determines if a request should be retried based on the error
    public func shouldRetry(error: NetworkError, attempt: Int) -> Bool {
        guard attempt < configuration.maxRetries else {
            return false
        }

        switch error {
        case .timeout, .noConnection:
            return true
        case .serverError(let statusCode):
            return configuration.retryableStatusCodes.contains(statusCode)
        case .httpError(let statusCode, _):
            return configuration.retryableStatusCodes.contains(statusCode)
        default:
            return false
        }
    }

    /// Gets the delay for the next retry attempt
    public func delayForRetry(attempt: Int) -> TimeInterval {
        configuration.delay(for: attempt)
    }

    /// Executes an operation with retry logic.
    ///
    /// - Parameters:
    ///   - maxRetries: Total number of attempts (including the first). Passing `nil` falls
    ///     back to `configuration.maxRetries`. The operation is **always executed at least
    ///     once** regardless of this value — `max(1, maxRetries)` is applied internally,
    ///     so `0` is treated the same as `1` (a single attempt, no retries).
    ///   - operation: The async throwing operation to execute.
    /// - Returns: The result of the operation.
    /// - Throws: The last `NetworkError` if all attempts are exhausted, or a non-retryable error immediately.
    public func execute<T>(
        maxRetries: Int? = nil,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        let retries = max(1, maxRetries ?? configuration.maxRetries)

        for attempt in 0..<retries {
            do {
                return try await operation()
            } catch let error as NetworkError {
                if shouldRetry(error: error, attempt: attempt) && attempt < retries - 1 {
                    let delay = delayForRetry(attempt: attempt)
                    try await Task.sleep(for: .seconds(delay))
                    continue
                }

                throw error
            } catch {
                throw error
            }
        }

        throw NetworkError.unknown("Retry failed: exhausted \(retries) attempts")
    }
}
