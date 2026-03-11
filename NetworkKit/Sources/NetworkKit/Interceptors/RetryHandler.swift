// RetryHandler.swift
// NetworkKit

import Foundation

/// Tuning parameters for retry behaviour.
///
/// All properties are `let`; `RetryConfiguration` is immutable and `Sendable`.
public struct RetryConfiguration: Sendable {

    // MARK: - Properties

    /// Maximum number of retry attempts (not counting the initial attempt).
    public let maxRetries: Int

    /// Minimum delay between retries in seconds.
    public let baseDelay: TimeInterval

    /// Upper bound for the computed retry delay in seconds.
    public let maxDelay: TimeInterval

    /// When `true`, delay grows as `baseDelay × 2^attempt`; otherwise it stays constant.
    public let exponentialBackoff: Bool

    /// HTTP status codes that should trigger a retry.
    public let retryableStatusCodes: Set<Int>

    // MARK: - Defaults

    /// Three retries with exponential back-off starting at 1 s, capped at 30 s.
    public static let `default` = RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        exponentialBackoff: true,
        retryableStatusCodes: [408, 429, 500, 502, 503, 504]
    )

    // MARK: - Initialiser

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

    // MARK: - Helpers

    /// Computes the sleep duration for a given attempt index (0-based).
    public func delay(for attempt: Int) -> TimeInterval {
        guard exponentialBackoff else { return baseDelay }
        return min(baseDelay * pow(2.0, Double(attempt)), maxDelay)
    }
}

// MARK: - RetryHandler

/// Wraps an async operation and re-executes it on retryable `NetworkError`s.
///
/// `RetryHandler` is a value type; it owns only immutable state and is therefore
/// automatically `Sendable`.
///
/// Uses **structured concurrency** (`Task.sleep`) so the delay respects cooperative
/// cancellation — the sleep is interrupted if the surrounding task is cancelled.
public struct RetryHandler: Sendable {

    private let configuration: RetryConfiguration

    public init(configuration: RetryConfiguration = .default) {
        self.configuration = configuration
    }

    // MARK: - Public API

    /// Returns `true` when the error is recoverable and we have attempts remaining.
    public func shouldRetry(error: NetworkError, attempt: Int) -> Bool {
        guard attempt < configuration.maxRetries else { return false }
        switch error {
        case .timeout, .noConnection:
            return true
        case .serverError(let code):
            return configuration.retryableStatusCodes.contains(code)
        case .httpError(let code, _):
            return configuration.retryableStatusCodes.contains(code)
        default:
            return false
        }
    }

    /// The delay (in seconds) before retry attempt `attempt`.
    public func delayForRetry(attempt: Int) -> TimeInterval {
        configuration.delay(for: attempt)
    }

    /// Executes `operation`, retrying up to `maxRetries` times on retryable errors.
    ///
    /// - Parameters:
    ///   - maxRetries: Override for the configured maximum. Pass `nil` to use the default.
    ///   - operation: The async throwing work to execute.
    /// - Returns: The first successful result.
    /// - Throws: The last `NetworkError` if all attempts are exhausted,
    ///           or any non-retryable error immediately.
    public func execute<T: Sendable>(
        maxRetries: Int? = nil,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        let limit = maxRetries ?? configuration.maxRetries
        var lastError: Error?

        for attempt in 0...limit {
            do {
                return try await operation()
            } catch let error as NetworkError {
                lastError = error

                guard shouldRetry(error: error, attempt: attempt), attempt < limit else {
                    throw error
                }

                // Cooperative sleep – honours Task cancellation.
                try await Task.sleep(for: .seconds(delayForRetry(attempt: attempt)))
            } catch {
                // Non-NetworkError: surface immediately, no retry.
                throw error
            }
        }

        throw lastError ?? NetworkError.unknown("Retry exhausted without error context")
    }
}
