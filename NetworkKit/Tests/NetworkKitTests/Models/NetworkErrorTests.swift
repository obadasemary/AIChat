// NetworkErrorTests.swift
// NetworkKitTests

import Testing
import Foundation
@testable import NetworkKit

@Suite("NetworkError")
struct NetworkErrorTests {

    // MARK: - fromStatusCode

    @Test("2xx status codes return nil")
    func test_whenSuccessStatusCode_thenReturnsNil() {
        for code in [200, 201, 204, 299] {
            #expect(NetworkError.fromStatusCode(code) == nil)
        }
    }

    @Test("401 maps to .unauthorized")
    func test_when401_thenUnauthorized() {
        #expect(NetworkError.fromStatusCode(401) == .unauthorized)
    }

    @Test("403 maps to .forbidden")
    func test_when403_thenForbidden() {
        #expect(NetworkError.fromStatusCode(403) == .forbidden)
    }

    @Test("404 maps to .notFound")
    func test_when404_thenNotFound() {
        #expect(NetworkError.fromStatusCode(404) == .notFound)
    }

    @Test("408 maps to .timeout")
    func test_when408_thenTimeout() {
        #expect(NetworkError.fromStatusCode(408) == .timeout)
    }

    @Test("5xx codes map to .serverError")
    func test_when5xx_thenServerError() {
        for code in [500, 502, 503, 504] {
            #expect(NetworkError.fromStatusCode(code) == .serverError(statusCode: code))
        }
    }

    @Test("Unrecognised codes map to .httpError")
    func test_whenUnknownCode_thenHttpError() {
        let error = NetworkError.fromStatusCode(422)
        #expect(error == .httpError(statusCode: 422, data: nil))
    }

    // MARK: - fromURLError

    @Test(".timedOut maps to .timeout")
    func test_whenTimedOut_thenTimeout() {
        let urlError = URLError(.timedOut)
        #expect(NetworkError.fromURLError(urlError) == .timeout)
    }

    @Test(".notConnectedToInternet maps to .noConnection")
    func test_whenNotConnected_thenNoConnection() {
        let urlError = URLError(.notConnectedToInternet)
        #expect(NetworkError.fromURLError(urlError) == .noConnection)
    }

    @Test(".networkConnectionLost maps to .noConnection")
    func test_whenConnectionLost_thenNoConnection() {
        let urlError = URLError(.networkConnectionLost)
        #expect(NetworkError.fromURLError(urlError) == .noConnection)
    }

    @Test(".cancelled maps to .cancelled")
    func test_whenCancelled_thenCancelled() {
        let urlError = URLError(.cancelled)
        #expect(NetworkError.fromURLError(urlError) == .cancelled)
    }

    @Test(".badURL maps to .invalidURL")
    func test_whenBadURL_thenInvalidURL() {
        let urlError = URLError(.badURL)
        #expect(NetworkError.fromURLError(urlError) == .invalidURL)
    }

    @Test("Unknown URLError maps to .unknown")
    func test_whenUnknownURLError_thenUnknown() {
        let urlError = URLError(.cannotFindHost)
        let result = NetworkError.fromURLError(urlError)
        if case .unknown = result { /* pass */ } else {
            Issue.record("Expected .unknown, got \(result)")
        }
    }

    // MARK: - errorDescription

    @Test("All cases surface a non-empty description")
    func test_whenAnyError_thenHasDescription() {
        let errors: [NetworkError] = [
            .invalidURL, .invalidRequest, .invalidResponse, .noData,
            .decodingFailed("msg"), .encodingFailed("msg"),
            .httpError(statusCode: 400, data: nil), .unauthorized, .forbidden,
            .notFound, .serverError(statusCode: 500), .timeout,
            .noConnection, .cancelled, .unknown("x")
        ]
        for error in errors {
            #expect(error.errorDescription?.isEmpty == false, "No description for \(error)")
        }
    }

    // MARK: - Equatable

    @Test("Identical cases are equal")
    func test_whenIdenticalCases_thenEqual() {
        #expect(NetworkError.timeout == NetworkError.timeout)
        #expect(NetworkError.decodingFailed("x") == NetworkError.decodingFailed("x"))
        #expect(NetworkError.serverError(statusCode: 500) == NetworkError.serverError(statusCode: 500))
    }

    @Test("Different cases are not equal")
    func test_whenDifferentCases_thenNotEqual() {
        #expect(NetworkError.timeout != NetworkError.noConnection)
        #expect(NetworkError.decodingFailed("a") != NetworkError.decodingFailed("b"))
        #expect(NetworkError.serverError(statusCode: 500) != NetworkError.serverError(statusCode: 503))
    }
}
