//
//  RetryHandlerTests.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Testing
import Foundation
@testable import AIChat

struct RetryHandlerTests {

    // MARK: - Should Retry Tests

    @Test("Should retry on timeout error")
    func test_whenTimeoutError_thenShouldRetry() {
        let handler = RetryHandler(configuration: .default)

        let result = handler.shouldRetry(error: .timeout, attempt: 0)

        #expect(result == true)
    }

    @Test("Should retry on no connection error")
    func test_whenNoConnectionError_thenShouldRetry() {
        let handler = RetryHandler(configuration: .default)

        let result = handler.shouldRetry(error: .noConnection, attempt: 0)

        #expect(result == true)
    }

    @Test("Should retry on 503 server error")
    func test_when503Error_thenShouldRetry() {
        let handler = RetryHandler(configuration: .default)

        let result = handler.shouldRetry(error: .serverError(statusCode: 503), attempt: 0)

        #expect(result == true)
    }

    @Test("Should retry on 429 rate limit error")
    func test_when429Error_thenShouldRetry() {
        let handler = RetryHandler(configuration: .default)

        let result = handler.shouldRetry(error: .httpError(statusCode: 429, data: nil), attempt: 0)

        #expect(result == true)
    }

    @Test("Should not retry on unauthorized error")
    func test_whenUnauthorizedError_thenShouldNotRetry() {
        let handler = RetryHandler(configuration: .default)

        let result = handler.shouldRetry(error: .unauthorized, attempt: 0)

        #expect(result == false)
    }

    @Test("Should not retry on not found error")
    func test_whenNotFoundError_thenShouldNotRetry() {
        let handler = RetryHandler(configuration: .default)

        let result = handler.shouldRetry(error: .notFound, attempt: 0)

        #expect(result == false)
    }

    @Test("Should not retry when max retries exceeded")
    func test_whenMaxRetriesExceeded_thenShouldNotRetry() {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3))

        let result = handler.shouldRetry(error: .timeout, attempt: 3)

        #expect(result == false)
    }

    // MARK: - Delay Calculation Tests

    @Test("Exponential backoff calculates correct delays")
    func test_whenExponentialBackoff_thenDelaysAreCorrect() {
        let config = RetryConfiguration(
            baseDelay: 1.0,
            exponentialBackoff: true
        )
        let handler = RetryHandler(configuration: config)

        #expect(handler.delayForRetry(attempt: 0) == 1.0)
        #expect(handler.delayForRetry(attempt: 1) == 2.0)
        #expect(handler.delayForRetry(attempt: 2) == 4.0)
        #expect(handler.delayForRetry(attempt: 3) == 8.0)
    }

    @Test("Delay respects max delay")
    func test_whenDelayExceedsMax_thenUsesMaxDelay() {
        let config = RetryConfiguration(
            baseDelay: 1.0,
            maxDelay: 5.0,
            exponentialBackoff: true
        )
        let handler = RetryHandler(configuration: config)

        #expect(handler.delayForRetry(attempt: 10) == 5.0)
    }

    @Test("Linear backoff returns constant delay")
    func test_whenLinearBackoff_thenDelayIsConstant() {
        let config = RetryConfiguration(
            baseDelay: 2.0,
            exponentialBackoff: false
        )
        let handler = RetryHandler(configuration: config)

        #expect(handler.delayForRetry(attempt: 0) == 2.0)
        #expect(handler.delayForRetry(attempt: 1) == 2.0)
        #expect(handler.delayForRetry(attempt: 5) == 2.0)
    }

    // MARK: - Execute with Retry Tests

    @Test("Execute succeeds on first attempt")
    func test_whenFirstAttemptSucceeds_thenReturnsResult() async throws {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3, baseDelay: 0.01))
        var attempts = 0

        let result = try await handler.execute {
            attempts += 1
            return "success"
        }

        #expect(result == "success")
        #expect(attempts == 1)
    }

    @Test("Execute throws non-retryable error immediately")
    func test_whenNonRetryableError_thenThrowsImmediately() async {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3, baseDelay: 0.01))
        var attempts = 0

        await #expect(throws: NetworkError.self) {
            try await handler.execute {
                attempts += 1
                throw NetworkError.unauthorized
            }
        }

        #expect(attempts == 1)
    }

    // MARK: - Configuration Tests

    @Test("Default configuration has correct values")
    func test_whenDefaultConfiguration_thenHasCorrectValues() {
        let config = RetryConfiguration.default

        #expect(config.maxRetries == 3)
        #expect(config.baseDelay == 1.0)
        #expect(config.maxDelay == 30.0)
        #expect(config.exponentialBackoff == true)
        #expect(config.retryableStatusCodes.contains(503))
        #expect(config.retryableStatusCodes.contains(429))
    }

    @Test("Custom configuration overrides defaults")
    func test_whenCustomConfiguration_thenOverridesDefaults() {
        let config = RetryConfiguration(
            maxRetries: 5,
            baseDelay: 0.5,
            maxDelay: 10.0,
            exponentialBackoff: false,
            retryableStatusCodes: [500, 502]
        )

        #expect(config.maxRetries == 5)
        #expect(config.baseDelay == 0.5)
        #expect(config.maxDelay == 10.0)
        #expect(config.exponentialBackoff == false)
        #expect(config.retryableStatusCodes == [500, 502])
    }
}
