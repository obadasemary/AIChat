// NetworkRequestTests.swift
// NetworkKitTests

import Testing
import Foundation
@testable import NetworkKit

@Suite("NetworkRequest")
struct NetworkRequestTests {

    // MARK: - Default values

    @Test("Default method is GET")
    func test_whenInit_thenDefaultMethodIsGet() {
        let request = NetworkRequest(path: "/users")
        #expect(request.method == .get)
    }

    @Test("Default timeout is 30 seconds")
    func test_whenInit_thenDefaultTimeoutIs30() {
        let request = NetworkRequest(path: "/users")
        #expect(request.timeoutInterval == 30)
    }

    @Test("Default cache policy is useProtocolCachePolicy")
    func test_whenInit_thenDefaultCachePolicyIsProtocol() {
        let request = NetworkRequest(path: "/users")
        #expect(request.cachePolicy == .useProtocolCachePolicy)
    }

    // MARK: - .get factory

    @Test(".get sets method and path")
    func test_whenGetFactory_thenSetsMethodAndPath() {
        let request = NetworkRequest.get("/items")
        #expect(request.path == "/items")
        #expect(request.method == .get)
    }

    @Test(".get preserves query parameters")
    func test_whenGetFactoryWithQuery_thenPreservesParameters() {
        let request = NetworkRequest.get("/items", queryParameters: ["page": "1", "size": "20"])
        #expect(request.queryParameters?["page"] == "1")
        #expect(request.queryParameters?["size"] == "20")
    }

    // MARK: - .post factory (Encodable)

    @Test(".post encodes body and sets Content-Type")
    func test_whenPostFactory_thenEncodesBodyAndSetsContentType() throws {
        struct Payload: Encodable { let name: String }
        let request = try NetworkRequest.post("/users", body: Payload(name: "Alice"))
        #expect(request.method == .post)
        #expect(request.headers?["Content-Type"] == "application/json")
        #expect(request.body != nil)
    }

    @Test(".post merges caller headers with Content-Type")
    func test_whenPostFactoryWithHeaders_thenMergesHeaders() throws {
        struct Payload: Encodable { let value: Int }
        let request = try NetworkRequest.post(
            "/data",
            body: Payload(value: 42),
            headers: ["X-Custom": "header"]
        )
        #expect(request.headers?["X-Custom"] == "header")
        #expect(request.headers?["Content-Type"] == "application/json")
    }

    // MARK: - .put factory

    @Test(".put encodes body and sets Content-Type")
    func test_whenPutFactory_thenEncodesBody() throws {
        struct Payload: Encodable { let id: Int }
        let request = try NetworkRequest.put("/items/1", body: Payload(id: 1))
        #expect(request.method == .put)
        #expect(request.headers?["Content-Type"] == "application/json")
    }

    // MARK: - .patch factory

    @Test(".patch encodes body and sets Content-Type")
    func test_whenPatchFactory_thenEncodesBody() throws {
        struct Payload: Encodable { let title: String }
        let request = try NetworkRequest.patch("/items/1", body: Payload(title: "New"))
        #expect(request.method == .patch)
        #expect(request.headers?["Content-Type"] == "application/json")
    }

    // MARK: - .delete factory

    @Test(".delete sets method and optional query params")
    func test_whenDeleteFactory_thenSetsMethodAndQuery() {
        let request = NetworkRequest.delete("/items/1", queryParameters: ["force": "true"])
        #expect(request.method == .delete)
        #expect(request.queryParameters?["force"] == "true")
    }

    // MARK: - Sendable

    @Test("NetworkRequest can be passed across actor boundary")
    func test_whenPassedAcrossActorBoundary_thenCompiles() async {
        // This test verifies that NetworkRequest is Sendable at the type level.
        // The compiler enforces this at build time; the test just confirms the runtime works.
        let request = NetworkRequest.get("/ping")
        let result = await Task.detached { request }.value
        #expect(result.path == "/ping")
    }
}
