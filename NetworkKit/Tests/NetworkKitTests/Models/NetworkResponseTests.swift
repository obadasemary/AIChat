// NetworkResponseTests.swift
// NetworkKitTests

import Testing
import Foundation
@testable import NetworkKit

@Suite("NetworkResponse")
struct NetworkResponseTests {

    // MARK: - isSuccess

    @Test("2xx responses are success")
    func test_when2xx_thenIsSuccess() {
        for code in [200, 201, 204, 299] {
            let response = NetworkResponse(data: Data(), statusCode: code)
            #expect(response.isSuccess, "Expected isSuccess for \(code)")
        }
    }

    @Test("Non-2xx responses are not success")
    func test_whenNon2xx_thenNotSuccess() {
        for code in [199, 300, 400, 401, 500] {
            let response = NetworkResponse(data: Data(), statusCode: code)
            #expect(!response.isSuccess, "Expected !isSuccess for \(code)")
        }
    }

    // MARK: - init?(data:response:request:)

    @Test("Returns nil for non-HTTP response")
    func test_whenNonHTTPResponse_thenNil() {
        let response = NetworkResponse(data: Data(), response: nil)
        #expect(response == nil)
    }

    @Test("Extracts statusCode from HTTPURLResponse")
    func test_whenHTTPResponse_thenExtractsStatusCode() throws {
        let url = try #require(URL(string: "https://example.com"))
        let http = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)
        let response = NetworkResponse(data: Data(), response: http)
        #expect(response?.statusCode == 201)
    }

    @Test("Extracts string headers from HTTPURLResponse")
    func test_whenHTTPResponseWithHeaders_thenExtractsHeaders() throws {
        let url = try #require(URL(string: "https://example.com"))
        let http = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        let response = NetworkResponse(data: Data(), response: http)
        #expect(response?.headers["Content-Type"] == "application/json")
    }

    // MARK: - decode

    @Test("Decodes valid JSON body")
    func test_whenValidJSON_thenDecodes() throws {
        struct Item: Decodable { let id: Int; let name: String }
        let json = Data("{\"id\": 7, \"name\": \"Widget\"}".utf8)
        let response = NetworkResponse(data: json, statusCode: 200)
        let item = try response.decode(Item.self)
        #expect(item.id == 7)
        #expect(item.name == "Widget")
    }

    @Test("Throws decodingFailed for invalid JSON")
    func test_whenInvalidJSON_thenThrowsDecodingFailed() {
        struct Item: Decodable { let id: Int }
        let response = NetworkResponse(data: Data("not-json".utf8), statusCode: 200)
        #expect(throws: NetworkError.self) {
            _ = try response.decode(Item.self)
        }
    }

    @Test("Throws decodingFailed for missing required field")
    func test_whenMissingRequiredField_thenThrowsDecodingFailed() {
        struct Item: Decodable { let requiredField: String }
        let response = NetworkResponse(data: Data("{\"other\": 1}".utf8), statusCode: 200)
        #expect(throws: NetworkError.self) {
            _ = try response.decode(Item.self)
        }
    }

    // MARK: - string

    @Test("Returns UTF-8 string for text body")
    func test_whenUTF8Data_thenReturnsString() {
        let response = NetworkResponse(data: Data("hello".utf8), statusCode: 200)
        #expect(response.string() == "hello")
    }

    @Test("Returns nil for non-UTF8 data")
    func test_whenNonUTF8Data_thenReturnsNil() {
        // ISO-Latin-1 bytes that are not valid UTF-8.
        let response = NetworkResponse(data: Data([0xFF, 0xFE]), statusCode: 200)
        #expect(response.string() == nil)
    }
}
