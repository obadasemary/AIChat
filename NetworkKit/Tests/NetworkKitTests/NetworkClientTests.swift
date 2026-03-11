// NetworkClientTests.swift
// NetworkKitTests

import Testing
import Foundation
@testable import NetworkKit

@Suite("NetworkClient")
struct NetworkClientTests {

    // MARK: - execute(_:)

    @Test("Returns response on success")
    func test_whenExecuteSucceeds_thenReturnsResponse() async throws {
        let mock = MockNetworkService()
        await mock.register(path: "/ping", response: .jsonString("{\"ok\": true}"))
        let client = NetworkClient(service: mock)

        let response = try await client.execute(.get("/ping"))

        #expect(response.isSuccess)
        #expect(response.string()?.contains("ok") == true)
    }

    @Test("Throws NetworkError on service failure")
    func test_whenServiceErrors_thenThrowsNetworkError() async {
        let mock = MockNetworkService(shouldAlwaysError: true, errorToThrow: .noConnection)
        let client = NetworkClient(service: mock)

        await #expect(throws: NetworkError.noConnection) {
            try await client.execute(.get("/anything"))
        }
    }

    // MARK: - execute(_:responseType:)

    @Test("Decodes typed response from JSON")
    func test_whenExecuteWithType_thenDecodesResponse() async throws {
        struct User: Decodable { let id: Int; let name: String }

        let mock = MockNetworkService()
        await mock.register(path: "/users/1", response: .jsonString("{\"id\": 1, \"name\": \"Alice\"}"))
        let client = NetworkClient(service: mock)

        let user: User = try await client.execute(.get("/users/1"), responseType: User.self)

        #expect(user.id == 1)
        #expect(user.name == "Alice")
    }

    @Test("Throws decodingFailed when response shape does not match")
    func test_whenBadJSON_thenThrowsDecodingFailed() async throws {
        struct Strict: Decodable { let requiredField: String }

        let mock = MockNetworkService()
        await mock.register(path: "/bad", response: .jsonString("{\"otherField\": 1}"))
        let client = NetworkClient(service: mock)

        await #expect(throws: NetworkError.self) {
            let _: Strict = try await client.execute(.get("/bad"), responseType: Strict.self)
        }
    }

    // MARK: - execute with custom decoder

    @Test("Custom JSONDecoder is used for date parsing")
    func test_whenCustomDecoder_thenParsesDate() async throws {
        struct TimestampedItem: Decodable { let createdAt: Date }

        let mock = MockNetworkService()
        await mock.register(
            path: "/ts",
            response: .jsonString("{\"createdAt\": \"2025-06-15T10:30:00Z\"}")
        )

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let client = NetworkClient(service: mock)
        let item: TimestampedItem = try await client.execute(
            .get("/ts"),
            responseType: TimestampedItem.self,
            decoder: decoder
        )

        #expect(item.createdAt != Date.distantPast)
    }

    // MARK: - executeWithRetry

    @Test("executeWithRetry returns response when service succeeds")
    func test_whenExecuteWithRetrySucceeds_thenReturnsResponse() async throws {
        let mock = MockNetworkService()
        await mock.register(path: "/retry", response: .jsonString("{\"done\": true}"))
        let client = NetworkClient(
            service: mock,
            retryConfiguration: RetryConfiguration(maxRetries: 2, baseDelay: 0.001)
        )

        let response = try await client.executeWithRetry(.get("/retry"))

        #expect(response.isSuccess)
    }

    @Test("executeWithRetry decodes typed response")
    func test_whenExecuteWithRetryAndType_thenDecodesResponse() async throws {
        struct Result: Decodable { let value: Int }

        let mock = MockNetworkService()
        await mock.register(path: "/data", response: .jsonString("{\"value\": 99}"))
        let client = NetworkClient(
            service: mock,
            retryConfiguration: RetryConfiguration(maxRetries: 2, baseDelay: 0.001)
        )

        let result: Result = try await client.executeWithRetry(.get("/data"), responseType: Result.self)
        #expect(result.value == 99)
    }

    // MARK: - Concurrent requests

    @Test("Multiple concurrent requests all succeed")
    func test_whenConcurrentRequests_thenAllSucceed() async throws {
        let mock = MockNetworkService()
        await mock.register(path: "/a", response: .jsonString("{\"id\": 1}"))
        await mock.register(path: "/b", response: .jsonString("{\"id\": 2}"))
        await mock.register(path: "/c", response: .jsonString("{\"id\": 3}"))

        let client = NetworkClient(service: mock)

        // Use structured concurrency (async let) for parallel fan-out.
        async let r1 = client.execute(.get("/a"))
        async let r2 = client.execute(.get("/b"))
        async let r3 = client.execute(.get("/c"))

        let responses = try await [r1, r2, r3]
        #expect(responses.allSatisfy { $0.isSuccess })
        #expect(responses.count == 3)
    }

    // MARK: - Logger integration

    @Test("Logger receives requestStarted and requestSucceeded events")
    func test_whenRequestSucceeds_thenLoggerReceivesEvents() async throws {
        actor EventCollector {
            private(set) var events: [NetworkLogEvent] = []
            func collect(_ event: NetworkLogEvent) { events.append(event) }
        }
        let collector = EventCollector()

        let mock = MockNetworkService()
        await mock.register(path: "/log-test", response: .jsonString("{}"))
        let client = NetworkClient(service: mock) { event in
            Task { await collector.collect(event) }
        }

        _ = try await client.execute(.get("/log-test"))

        // Small yield to let the fire-and-forget Task run.
        try await Task.sleep(for: .milliseconds(50))

        let events = await collector.events
        let hasStarted   = events.contains { if case .requestStarted   = $0 { return true }; return false }
        let hasSucceeded = events.contains { if case .requestSucceeded = $0 { return true }; return false }
        #expect(hasStarted)
        #expect(hasSucceeded)
    }

    @Test("Logger receives requestFailed event on error")
    func test_whenRequestFails_thenLoggerReceivesFailedEvent() async throws {
        actor EventCollector {
            private(set) var events: [NetworkLogEvent] = []
            func collect(_ event: NetworkLogEvent) { events.append(event) }
        }
        let collector = EventCollector()

        let mock = MockNetworkService(shouldAlwaysError: true, errorToThrow: .timeout)
        let client = NetworkClient(service: mock) { event in
            Task { await collector.collect(event) }
        }

        _ = try? await client.execute(.get("/fail"))
        try await Task.sleep(for: .milliseconds(50))

        let events = await collector.events
        let hasFailed = events.contains { if case .requestFailed = $0 { return true }; return false }
        #expect(hasFailed)
    }

    // MARK: - Recorded requests

    @Test("Service records the executed request")
    func test_whenRequestExecuted_thenServiceRecordsIt() async throws {
        let mock = MockNetworkService()
        await mock.register(path: "/check", response: .jsonString("{}"))
        let client = NetworkClient(service: mock)

        _ = try await client.execute(.get("/check"))

        let recorded = await mock.recordedRequests
        #expect(recorded.count == 1)
        #expect(recorded.first?.path == "/check")
    }
}
