//
//  NetworkRequestTests.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Testing
import Foundation
@testable import AIChat

struct NetworkRequestTests {

    // MARK: - Initialization Tests

    @Test("Default request initializes with correct values")
    func test_whenDefaultInit_thenHasCorrectDefaults() {
        let request = NetworkRequest(path: "/api/test")

        #expect(request.path == "/api/test")
        #expect(request.method == .get)
        #expect(request.queryParameters == nil)
        #expect(request.headers == nil)
        #expect(request.body == nil)
        #expect(request.timeoutInterval == 30)
        #expect(request.cachePolicy == .useProtocolCachePolicy)
    }

    @Test("Request initializes with all parameters")
    func test_whenFullInit_thenHasAllParameters() {
        let body = Data("test".utf8)
        let request = NetworkRequest(
            path: "/api/test",
            method: .post,
            queryParameters: ["key": "value"],
            headers: ["Authorization": "Bearer token"],
            body: body,
            timeoutInterval: 60,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        #expect(request.path == "/api/test")
        #expect(request.method == .post)
        #expect(request.queryParameters == ["key": "value"])
        #expect(request.headers == ["Authorization": "Bearer token"])
        #expect(request.body == body)
        #expect(request.timeoutInterval == 60)
        #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
    }

    // MARK: - Static Factory Method Tests

    @Test("GET request factory creates correct request")
    func test_whenGetFactory_thenCreatesGetRequest() {
        let request = NetworkRequest.get(
            "/api/users",
            queryParameters: ["page": "1"],
            headers: ["Accept": "application/json"]
        )

        #expect(request.method == .get)
        #expect(request.path == "/api/users")
        #expect(request.queryParameters == ["page": "1"])
        #expect(request.headers == ["Accept": "application/json"])
        #expect(request.body == nil)
    }

    @Test("POST request factory creates correct request with JSON body")
    func test_whenPostFactory_thenCreatesPostRequest() throws {
        struct TestBody: Codable {
            let name: String
            let value: Int
        }

        let body = TestBody(name: "test", value: 42)
        let request = try NetworkRequest.post("/api/items", body: body)

        #expect(request.method == .post)
        #expect(request.path == "/api/items")
        #expect(request.headers?["Content-Type"] == "application/json")
        #expect(request.body != nil)
    }

    @Test("POST request with data creates correct request")
    func test_whenPostWithData_thenCreatesPostRequest() {
        let data = Data("raw data".utf8)
        let request = NetworkRequest.post(
            "/api/upload",
            data: data,
            contentType: "text/plain"
        )

        #expect(request.method == .post)
        #expect(request.headers?["Content-Type"] == "text/plain")
        #expect(request.body == data)
    }

    @Test("PUT request factory creates correct request")
    func test_whenPutFactory_thenCreatesPutRequest() throws {
        struct UpdateBody: Codable {
            let id: Int
            let name: String
        }

        let body = UpdateBody(id: 1, name: "updated")
        let request = try NetworkRequest.put("/api/items/1", body: body)

        #expect(request.method == .put)
        #expect(request.path == "/api/items/1")
        #expect(request.headers?["Content-Type"] == "application/json")
        #expect(request.body != nil)
    }

    @Test("PATCH request factory creates correct request")
    func test_whenPatchFactory_thenCreatesPatchRequest() throws {
        struct PatchBody: Codable {
            let name: String
        }

        let body = PatchBody(name: "patched")
        let request = try NetworkRequest.patch("/api/items/1", body: body)

        #expect(request.method == .patch)
        #expect(request.headers?["Content-Type"] == "application/json")
    }

    @Test("DELETE request factory creates correct request")
    func test_whenDeleteFactory_thenCreatesDeleteRequest() {
        let request = NetworkRequest.delete(
            "/api/items/1",
            queryParameters: ["force": "true"]
        )

        #expect(request.method == .delete)
        #expect(request.path == "/api/items/1")
        #expect(request.queryParameters == ["force": "true"])
        #expect(request.body == nil)
    }

    // MARK: - Timeout Tests

    @Test("Custom timeout is preserved")
    func test_whenCustomTimeout_thenIsPreserved() {
        let request = NetworkRequest.get("/api/slow", timeoutInterval: 120)

        #expect(request.timeoutInterval == 120)
    }
}
