//
//  RetryInterceptor.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Configuration for retry behavior
struct RetryConfiguration: Sendable {
    /// Maximum number of retry attempts
    let maxRetries: Int

    /// Base delay between retries in seconds
    let baseDelay: TimeInterval

    /// Maximum delay between retries in seconds
    let maxDelay: TimeInterval

    /// Whether to use exponential backoff
    let exponentialBackoff: Bool

    /// Status codes that should trigger a retry
    let retryableStatusCodes: Set<Int>

    /// Default retry configuration
    static let `default` = RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        exponentialBackoff: true,
        retryableStatusCodes: [408, 429, 500, 502, 503, 504]
    )

    /// Creates a custom retry configuration
    init(
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
    func delay(for attempt: Int) -> TimeInterval {
        if exponentialBackoff {
            let delay = baseDelay * pow(2.0, Double(attempt))
            return min(delay, maxDelay)
        }
        return baseDelay
    }
}

/// A helper that provides retry functionality for network requests
/// Note: This is not an interceptor but a wrapper that can be used by NetworkManager
struct RetryHandler: Sendable {
    private let configuration: RetryConfiguration

    init(configuration: RetryConfiguration = .default) {
        self.configuration = configuration
    }

    /// Determines if a request should be retried based on the error
    func shouldRetry(error: NetworkError, attempt: Int) -> Bool {
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
    func delayForRetry(attempt: Int) -> TimeInterval {
        configuration.delay(for: attempt)
    }

    /// Executes a request with retry logic
    func execute<T>(
        maxRetries: Int? = nil,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        let retries = maxRetries ?? configuration.maxRetries
        var lastError: Error?

        for attempt in 0...retries {
            do {
                return try await operation()
            } catch let error as NetworkError {
                lastError = error

                if shouldRetry(error: error, attempt: attempt) && attempt < retries {
                    let delay = delayForRetry(attempt: attempt)
                    try await Task.sleep(for: .seconds(delay))
                    continue
                }

                throw error
            } catch {
                throw error
            }
        }

        throw lastError ?? NetworkError.unknown("Retry failed")
    }
}
