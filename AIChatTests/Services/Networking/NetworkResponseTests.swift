//
//  NetworkResponseTests.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Testing
import Foundation
@testable import AIChat

struct NetworkResponseTests {

    // MARK: - Initialization Tests

    @Test("Response initializes with correct values")
    func test_whenInit_thenHasCorrectValues() {
        let data = Data("test".utf8)
        let response = NetworkResponse(
            data: data,
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )

        #expect(response.data == data)
        #expect(response.statusCode == 200)
        #expect(response.headers["Content-Type"] == "application/json")
    }

    // MARK: - Success Tests

    @Test("2xx status codes are success")
    func test_when2xxStatusCode_thenIsSuccess() {
        let successCodes = [200, 201, 202, 204, 299]

        for code in successCodes {
            let response = NetworkResponse(data: Data(), statusCode: code)
            #expect(response.isSuccess == true, "Status code \(code) should be success")
        }
    }

    @Test("Non-2xx status codes are not success")
    func test_whenNon2xxStatusCode_thenIsNotSuccess() {
        let failureCodes = [400, 401, 403, 404, 500, 503]

        for code in failureCodes {
            let response = NetworkResponse(data: Data(), statusCode: code)
            #expect(response.isSuccess == false, "Status code \(code) should not be success")
        }
    }

    // MARK: - Decoding Tests

    @Test("Decode valid JSON succeeds")
    func test_whenValidJSON_thenDecodeSucceeds() throws {
        struct TestModel: Decodable {
            let id: Int
            let name: String
        }

        let json = """
        {"id": 1, "name": "Test"}
        """
        let data = Data(json.utf8)
        let response = NetworkResponse(data: data, statusCode: 200)

        let decoded = try response.decode(TestModel.self)

        #expect(decoded.id == 1)
        #expect(decoded.name == "Test")
    }

    @Test("Decode invalid JSON throws error")
    func test_whenInvalidJSON_thenDecodeThrows() {
        struct TestModel: Decodable {
            let id: Int
        }

        let data = Data("invalid json".utf8)
        let response = NetworkResponse(data: data, statusCode: 200)

        #expect(throws: NetworkError.self) {
            try response.decode(TestModel.self)
        }
    }

    @Test("Decode with custom decoder succeeds")
    func test_whenCustomDecoder_thenDecodeSucceeds() throws {
        struct DateModel: Decodable {
            let date: Date
        }

        let json = """
        {"date": "2025-01-15T12:00:00Z"}
        """
        let data = Data(json.utf8)
        let response = NetworkResponse(data: data, statusCode: 200)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try response.decode(DateModel.self, decoder: decoder)

        #expect(decoded.date != Date.distantPast)
    }

    // MARK: - String Conversion Tests

    @Test("String conversion with UTF8 succeeds")
    func test_whenUTF8Data_thenStringConversionSucceeds() {
        let data = Data("Hello, World!".utf8)
        let response = NetworkResponse(data: data, statusCode: 200)

        let string = response.string()

        #expect(string == "Hello, World!")
    }

    @Test("String conversion with custom encoding")
    func test_whenCustomEncoding_thenStringConversionWorks() {
        let data = Data("Test".utf8)
        let response = NetworkResponse(data: data, statusCode: 200)

        let string = response.string(encoding: .utf8)

        #expect(string == "Test")
    }

    // MARK: - URLResponse Initialization Tests

    @Test("Init from URLResponse with valid HTTP response succeeds")
    func test_whenValidHTTPResponse_thenInitSucceeds() {
        let data = Data("test".utf8)
        let url = URL(string: "https://api.example.com/test")
        let httpResponse = HTTPURLResponse(
            url: url!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )

        let response = NetworkResponse(data: data, response: httpResponse)

        #expect(response != nil)
        #expect(response?.statusCode == 200)
        #expect(response?.headers["Content-Type"] == "application/json")
    }

    @Test("Init from non-HTTP response returns nil")
    func test_whenNonHTTPResponse_thenInitReturnsNil() {
        let data = Data("test".utf8)
        let url = URL(string: "https://api.example.com/test")!
        let urlResponse = URLResponse(
            url: url,
            mimeType: "application/json",
            expectedContentLength: 4,
            textEncodingName: nil
        )

        let response = NetworkResponse(data: data, response: urlResponse)

        #expect(response == nil)
    }
}
