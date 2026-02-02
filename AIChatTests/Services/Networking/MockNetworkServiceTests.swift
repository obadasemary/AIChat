//
//  MockNetworkServiceTests.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Testing
import Foundation
@testable import AIChat

@MainActor
struct MockNetworkServiceTests {

    // MARK: - Basic Execution Tests

    @Test("Execute returns default empty response when no mock registered")
    func test_whenNoMockRegistered_thenReturnsEmptyResponse() async throws {
        let service = MockNetworkService(delay: 0)
        let request = NetworkRequest.get("/api/test")

        let response = try await service.execute(request)

        #expect(response.statusCode == 200)
        #expect(response.data.isEmpty)
    }

    @Test("Execute returns registered mock response")
    func test_whenMockRegistered_thenReturnsMockResponse() async throws {
        let service = MockNetworkService(delay: 0)
        let mockData = Data("{\"id\": 1}".utf8)
        service.register(path: "/api/test", response: .init(data: mockData, statusCode: 200))

        let request = NetworkRequest.get("/api/test")
        let response = try await service.execute(request)

        #expect(response.statusCode == 200)
        #expect(response.data == mockData)
    }

    @Test("Execute records requests")
    func test_whenExecute_thenRecordsRequest() async throws {
        let service = MockNetworkService(delay: 0)
        let request = NetworkRequest.get("/api/test")

        _ = try await service.execute(request)

        #expect(service.recordedRequests.count == 1)
        #expect(service.recordedRequests.first?.path == "/api/test")
    }

    // MARK: - Error Simulation Tests

    @Test("Execute throws error when shouldError is true")
    func test_whenShouldError_thenThrowsError() async {
        let service = MockNetworkService(
            delay: 0,
            shouldError: true,
            errorToThrow: .noConnection
        )
        let request = NetworkRequest.get("/api/test")

        await #expect(throws: NetworkError.self) {
            try await service.execute(request)
        }
    }

    @Test("Execute throws error for error status code")
    func test_whenErrorStatusCode_thenThrowsError() async {
        let service = MockNetworkService(delay: 0)
        service.register(
            path: "/api/error",
            response: .init(data: Data(), statusCode: 404)
        )

        let request = NetworkRequest.get("/api/error")

        await #expect(throws: NetworkError.self) {
            try await service.execute(request)
        }
    }

    // MARK: - JSON Response Tests

    @Test("Register JSON object creates correct response")
    func test_whenRegisterJSONObject_thenCreatesCorrectResponse() async throws {
        struct TestModel: Codable, Equatable {
            let id: Int
            let name: String
        }

        let service = MockNetworkService(delay: 0)
        let model = TestModel(id: 1, name: "Test")
        try service.register(path: "/api/model", object: model)

        let request = NetworkRequest.get("/api/model")
        let response = try await service.execute(request)

        let decoded = try JSONDecoder().decode(TestModel.self, from: response.data)
        #expect(decoded == model)
    }

    @Test("JSON string mock creates correct response")
    func test_whenJSONStringMock_thenCreatesCorrectResponse() async throws {
        let service = MockNetworkService(delay: 0)
        let json = "{\"status\": \"ok\"}"
        service.register(path: "/api/status", response: .jsonString(json))

        let request = NetworkRequest.get("/api/status")
        let response = try await service.execute(request)

        #expect(response.headers["Content-Type"] == "application/json")
        #expect(response.string() == json)
    }

    // MARK: - Cleanup Tests

    @Test("Clear recorded requests removes all requests")
    func test_whenClearRecordedRequests_thenRequestsAreEmpty() async throws {
        let service = MockNetworkService(delay: 0)

        _ = try await service.execute(NetworkRequest.get("/api/test1"))
        _ = try await service.execute(NetworkRequest.get("/api/test2"))

        service.clearRecordedRequests()

        #expect(service.recordedRequests.isEmpty)
    }

    @Test("Clear mock responses returns default response")
    func test_whenClearMockResponses_thenReturnsDefaultResponse() async throws {
        let service = MockNetworkService(delay: 0)
        service.register(path: "/api/test", response: .jsonString("{\"id\": 1}"))

        service.clearMockResponses()

        let response = try await service.execute(NetworkRequest.get("/api/test"))
        #expect(response.data.isEmpty)
    }

    // MARK: - Delay Tests

    @Test("Execute respects delay")
    func test_whenDelaySet_thenExecutionIsDelayed() async throws {
        let service = MockNetworkService(delay: 0.1)

        let start = Date()
        _ = try await service.execute(NetworkRequest.get("/api/test"))
        let elapsed = Date().timeIntervalSince(start)

        #expect(elapsed >= 0.1)
    }
}
