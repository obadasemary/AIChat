//
//  NetworkManagerTests.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Testing
import Foundation
@testable import AIChat

@MainActor
struct NetworkManagerTests {

    // MARK: - Execute Tests

    @Test("Execute returns successful response")
    func test_whenExecuteSucceeds_thenReturnsResponse() async throws {
        let mockService = MockNetworkService(delay: 0)
        mockService.register(
            path: "/api/test",
            response: .jsonString("{\"status\": \"ok\"}")
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/test")

        let response = try await manager.execute(request)

        #expect(response.isSuccess)
        #expect(response.string() == "{\"status\": \"ok\"}")
    }

    @Test("Execute throws error on failure")
    func test_whenExecuteFails_thenThrowsError() async {
        let mockService = MockNetworkService(
            delay: 0,
            shouldError: true,
            errorToThrow: .noConnection
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/test")

        await #expect(throws: NetworkError.self) {
            try await manager.execute(request)
        }
    }

    // MARK: - Typed Response Tests

    @Test("Execute with response type decodes correctly")
    func test_whenExecuteWithType_thenDecodesResponse() async throws {
        struct TestResponse: Decodable {
            let id: Int
            let name: String
        }

        let mockService = MockNetworkService(delay: 0)
        mockService.register(
            path: "/api/user",
            response: .jsonString("{\"id\": 123, \"name\": \"John\"}")
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/user")

        let result: TestResponse = try await manager.execute(request, responseType: TestResponse.self)

        #expect(result.id == 123)
        #expect(result.name == "John")
    }

    @Test("Execute with response type throws on decode failure")
    func test_whenDecodeFailure_thenThrowsError() async {
        struct TestResponse: Decodable {
            let requiredField: String
        }

        let mockService = MockNetworkService(delay: 0)
        mockService.register(
            path: "/api/invalid",
            response: .jsonString("{\"otherField\": \"value\"}")
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/invalid")

        await #expect(throws: NetworkError.self) {
            let _: TestResponse = try await manager.execute(request, responseType: TestResponse.self)
        }
    }

    // MARK: - Retry Tests

    @Test("Execute with retry succeeds on first attempt")
    func test_whenExecuteWithRetrySucceeds_thenReturnsResponse() async throws {
        let mockService = MockNetworkService(delay: 0)
        mockService.register(
            path: "/api/test",
            response: .jsonString("{\"success\": true}")
        )

        let manager = NetworkManager(
            service: mockService,
            retryConfiguration: RetryConfiguration(maxRetries: 3, baseDelay: 0.01)
        )
        let request = NetworkRequest.get("/api/test")

        let response = try await manager.executeWithRetry(request)

        #expect(response.isSuccess)
    }

    @Test("Execute with retry and type succeeds")
    func test_whenExecuteWithRetryAndType_thenDecodesResponse() async throws {
        struct TestResponse: Decodable {
            let value: Int
        }

        let mockService = MockNetworkService(delay: 0)
        mockService.register(
            path: "/api/data",
            response: .jsonString("{\"value\": 42}")
        )

        let manager = NetworkManager(
            service: mockService,
            retryConfiguration: RetryConfiguration(maxRetries: 3, baseDelay: 0.01)
        )
        let request = NetworkRequest.get("/api/data")

        let result: TestResponse = try await manager.executeWithRetry(
            request,
            responseType: TestResponse.self
        )

        #expect(result.value == 42)
    }

    // MARK: - Custom Decoder Tests

    @Test("Execute with custom decoder parses dates correctly")
    func test_whenCustomDecoder_thenParsesCorrectly() async throws {
        struct DateResponse: Decodable {
            let createdAt: Date
        }

        let mockService = MockNetworkService(delay: 0)
        mockService.register(
            path: "/api/date",
            response: .jsonString("{\"createdAt\": \"2025-06-15T10:30:00Z\"}")
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/date")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let result: DateResponse = try await manager.execute(
            request,
            responseType: DateResponse.self,
            decoder: decoder
        )

        #expect(result.createdAt != Date.distantPast)
    }

    // MARK: - Multiple Requests Tests

    @Test("Multiple concurrent requests succeed")
    func test_whenMultipleConcurrentRequests_thenAllSucceed() async throws {
        let mockService = MockNetworkService(delay: 0)
        mockService.register(path: "/api/1", response: .jsonString("{\"id\": 1}"))
        mockService.register(path: "/api/2", response: .jsonString("{\"id\": 2}"))
        mockService.register(path: "/api/3", response: .jsonString("{\"id\": 3}"))

        let manager = NetworkManager(service: mockService)

        async let response1 = manager.execute(NetworkRequest.get("/api/1"))
        async let response2 = manager.execute(NetworkRequest.get("/api/2"))
        async let response3 = manager.execute(NetworkRequest.get("/api/3"))

        let responses = try await [response1, response2, response3]

        #expect(responses.allSatisfy { $0.isSuccess })
        #expect(responses.count == 3)
    }
}
