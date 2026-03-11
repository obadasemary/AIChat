// RetryHandlerTests.swift
// NetworkKitTests

import Testing
import Foundation
@testable import NetworkKit

@Suite("RetryHandler")
struct RetryHandlerTests {

    // MARK: - Helpers

    /// Thread-safe attempt counter using an actor — no locks needed.
    private actor AttemptCounter {
        private(set) var count = 0
        func increment() { count += 1 }
    }

    // MARK: - shouldRetry

    @Test("Retries on .timeout")
    func test_whenTimeout_thenShouldRetry() {
        let handler = RetryHandler()
        #expect(handler.shouldRetry(error: .timeout, attempt: 0) == true)
    }

    @Test("Retries on .noConnection")
    func test_whenNoConnection_thenShouldRetry() {
        let handler = RetryHandler()
        #expect(handler.shouldRetry(error: .noConnection, attempt: 0) == true)
    }

    @Test("Retries on retryable server error 503")
    func test_when503_thenShouldRetry() {
        let handler = RetryHandler()
        #expect(handler.shouldRetry(error: .serverError(statusCode: 503), attempt: 0) == true)
    }

    @Test("Retries on retryable HTTP error 429")
    func test_when429_thenShouldRetry() {
        let handler = RetryHandler()
        #expect(handler.shouldRetry(error: .httpError(statusCode: 429, data: nil), attempt: 0) == true)
    }

    @Test("Does not retry on .unauthorized")
    func test_whenUnauthorized_thenNoRetry() {
        let handler = RetryHandler()
        #expect(handler.shouldRetry(error: .unauthorized, attempt: 0) == false)
    }

    @Test("Does not retry on .notFound")
    func test_whenNotFound_thenNoRetry() {
        let handler = RetryHandler()
        #expect(handler.shouldRetry(error: .notFound, attempt: 0) == false)
    }

    @Test("Does not retry when max attempts reached")
    func test_whenMaxAttemptsReached_thenNoRetry() {
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3))
        #expect(handler.shouldRetry(error: .timeout, attempt: 3) == false)
    }

    // MARK: - delayForRetry

    @Test("Exponential backoff doubles each attempt")
    func test_whenExponentialBackoff_thenDelaysDouble() {
        let config = RetryConfiguration(baseDelay: 1.0, exponentialBackoff: true)
        let handler = RetryHandler(configuration: config)
        #expect(handler.delayForRetry(attempt: 0) == 1.0)
        #expect(handler.delayForRetry(attempt: 1) == 2.0)
        #expect(handler.delayForRetry(attempt: 2) == 4.0)
        #expect(handler.delayForRetry(attempt: 3) == 8.0)
    }

    @Test("Delay is capped at maxDelay")
    func test_whenDelayExceedsMax_thenCapped() {
        let config = RetryConfiguration(baseDelay: 1.0, maxDelay: 5.0, exponentialBackoff: true)
        let handler = RetryHandler(configuration: config)
        #expect(handler.delayForRetry(attempt: 10) == 5.0)
    }

    @Test("Linear backoff keeps delay constant")
    func test_whenLinearBackoff_thenConstantDelay() {
        let config = RetryConfiguration(baseDelay: 2.0, exponentialBackoff: false)
        let handler = RetryHandler(configuration: config)
        #expect(handler.delayForRetry(attempt: 0) == 2.0)
        #expect(handler.delayForRetry(attempt: 5) == 2.0)
    }

    // MARK: - execute

    @Test("Succeeds on first attempt and calls operation once")
    func test_whenFirstAttemptSucceeds_thenCalledOnce() async throws {
        let counter = AttemptCounter()
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3, baseDelay: 0.001))

        let result = try await handler.execute {
            await counter.increment()
            return "ok"
        }

        #expect(result == "ok")
        #expect(await counter.count == 1)
    }

    @Test("Does not retry non-retryable errors")
    func test_whenNonRetryableError_thenThrowsImmediately() async throws {
        let counter = AttemptCounter()
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3, baseDelay: 0.001))

        await #expect(throws: NetworkError.unauthorized) {
            try await handler.execute {
                await counter.increment()
                throw NetworkError.unauthorized
            }
        }

        #expect(await counter.count == 1)
    }

    @Test("Retries retryable errors up to limit")
    func test_whenRetryableError_thenRetriesUpToLimit() async throws {
        let counter = AttemptCounter()
        let limit = 3
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: limit, baseDelay: 0.001))

        await #expect(throws: NetworkError.timeout) {
            try await handler.execute {
                await counter.increment()
                throw NetworkError.timeout
            }
        }

        // Initial attempt + 3 retries = 4 total calls
        #expect(await counter.count == limit + 1)
    }

    @Test("Succeeds after transient failures")
    func test_whenTransientFailureThenSuccess_thenReturnsResult() async throws {
        let counter = AttemptCounter()
        let handler = RetryHandler(configuration: RetryConfiguration(maxRetries: 3, baseDelay: 0.001))

        let result = try await handler.execute {
            await counter.increment()
            let attempt = await counter.count
            if attempt < 3 { throw NetworkError.timeout }
            return "recovered"
        }

        #expect(result == "recovered")
        #expect(await counter.count == 3)
    }

    // MARK: - RetryConfiguration defaults

    @Test("Default configuration values")
    func test_whenDefaultConfiguration_thenCorrectValues() {
        let config = RetryConfiguration.default
        #expect(config.maxRetries == 3)
        #expect(config.baseDelay == 1.0)
        #expect(config.maxDelay == 30.0)
        #expect(config.exponentialBackoff == true)
        #expect(config.retryableStatusCodes.contains(503))
        #expect(config.retryableStatusCodes.contains(429))
    }
}
