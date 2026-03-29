//
//  RetryHandlerTests.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Testing
import Foundation
import NetworkingKit

struct RetryHandlerTests {
    private actor AttemptCounter {
        private var count = 0

        func increment() {
            count += 1
        }

        func value() -> Int {
            count
        }
    }

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

    // MARK: - shouldRetry maxRetries Override Tests

    @Test("shouldRetry respects explicit maxRetries override above configuration value")
    func test_whenExplicitMaxRetriesAboveConfig_thenShouldRetryUpToOverrideCeiling() {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 2))

        // Attempt 4 is beyond config.maxRetries (2) but within override (5)
        let resultWithinOverride = handler.shouldRetry(error: .timeout, attempt: 4, maxRetries: 5)
        // Attempt 5 equals the override ceiling — should not retry
        let resultAtOverrideCeiling = handler.shouldRetry(error: .timeout, attempt: 5, maxRetries: 5)

        #expect(resultWithinOverride == true)
        #expect(resultAtOverrideCeiling == false)
    }

    @Test("shouldRetry respects explicit maxRetries override below configuration value")
    func test_whenExplicitMaxRetriesBelowConfig_thenShouldNotRetryBeyondOverride() {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 5))

        // Attempt 2 equals the override ceiling — config would allow more, override must win
        let resultAtOverrideCeiling = handler.shouldRetry(error: .timeout, attempt: 2, maxRetries: 2)
        // Attempt 1 is within the override ceiling — should retry
        let resultBelowOverride = handler.shouldRetry(error: .timeout, attempt: 1, maxRetries: 2)

        #expect(resultAtOverrideCeiling == false)
        #expect(resultBelowOverride == true)
    }

    @Test("shouldRetry with override zero never retries")
    func test_whenExplicitMaxRetriesIsZero_thenShouldNeverRetry() {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3))

        let result = handler.shouldRetry(error: .timeout, attempt: 0, maxRetries: 0)

        #expect(result == false)
    }

    @Test("shouldRetry override does not change retryable error logic")
    func test_whenExplicitMaxRetriesOverride_thenNonRetryableErrorStillRejected() {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 1))

        // Even though override lifts ceiling, unauthorized is never retryable
        let result = handler.shouldRetry(error: .unauthorized, attempt: 0, maxRetries: 10)

        #expect(result == false)
    }

    // MARK: - execute(maxAttempts:) Override Tests

    @Test("execute with maxAttempts above configuration retries up to overridden ceiling")
    func test_whenMaxAttemptsAboveConfig_thenRetriesUpToOverride() async throws {
        // Config allows 2 retries (3 total). We pass maxAttempts: 5 → 5 total attempts.
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 2, baseDelay: 0.0))
        let attempts = AttemptCounter()

        await #expect(throws: NetworkError.self) {
            try await handler.execute(maxAttempts: 5) {
                await attempts.increment()
                throw NetworkError.timeout
            }
        }

        #expect(await attempts.value() == 5)
    }

    @Test("execute with maxAttempts above configuration stops after override ceiling")
    func test_whenMaxAttemptsAboveConfig_thenStopsExactlyAtOverride() async throws {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 2, baseDelay: 0.0))
        let attempts = AttemptCounter()

        await #expect(throws: NetworkError.self) {
            try await handler.execute(maxAttempts: 4) {
                await attempts.increment()
                throw NetworkError.noConnection
            }
        }

        // Must be exactly 4, not 3 (config default) and not more than 4
        #expect(await attempts.value() == 4)
    }

    @Test("execute with maxAttempts above configuration succeeds when operation recovers within override window")
    func test_whenMaxAttemptsAboveConfig_thenSucceedsOnAttemptWithinOverride() async throws {
        // Config allows 2 retries; override raises ceiling to 5. Succeed on attempt 4.
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 2, baseDelay: 0.0))
        let attempts = AttemptCounter()

        let result = try await handler.execute(maxAttempts: 5) {
            let count = await attempts.value()
            await attempts.increment()
            if count < 3 {
                throw NetworkError.timeout
            }
            return "recovered"
        }

        #expect(result == "recovered")
        #expect(await attempts.value() == 4)
    }

    @Test("execute with maxAttempts one makes exactly one attempt regardless of configuration")
    func test_whenMaxAttemptsIsOne_thenMakesExactlyOneAttempt() async {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 5, baseDelay: 0.0))
        let attempts = AttemptCounter()

        await #expect(throws: NetworkError.self) {
            try await handler.execute(maxAttempts: 1) {
                await attempts.increment()
                throw NetworkError.timeout
            }
        }

        #expect(await attempts.value() == 1)
    }

    // MARK: - Execute with Retry Tests

    @Test("Execute succeeds on first attempt")
    func test_whenFirstAttemptSucceeds_thenReturnsResult() async throws {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3, baseDelay: 0.01))
        let attempts = AttemptCounter()

        let result = try await handler.execute {
            await attempts.increment()
            return "success"
        }

        #expect(result == "success")
        #expect(await attempts.value() == 1)
    }

    @Test("Execute throws non-retryable error immediately")
    func test_whenNonRetryableError_thenThrowsImmediately() async {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3, baseDelay: 0.01))
        let attempts = AttemptCounter()

        await #expect(throws: NetworkError.self) {
            try await handler.execute {
                await attempts.increment()
                throw NetworkError.unauthorized
            }
        }

        #expect(await attempts.value() == 1)
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
