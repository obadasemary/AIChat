//
//  NetworkErrorTests.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Testing
import Foundation
@testable import AIChat

struct NetworkErrorTests {

    // MARK: - Error Description Tests

    @Test("Invalid URL error has correct description")
    func test_whenInvalidURLError_thenDescriptionIsCorrect() {
        let error = NetworkError.invalidURL
        #expect(error.errorDescription == "The URL is invalid.")
    }

    @Test("Unauthorized error has correct description")
    func test_whenUnauthorizedError_thenDescriptionIsCorrect() {
        let error = NetworkError.unauthorized
        #expect(error.errorDescription == "Authentication required. Please sign in again.")
    }

    @Test("No connection error has correct description")
    func test_whenNoConnectionError_thenDescriptionIsCorrect() {
        let error = NetworkError.noConnection
        #expect(error.errorDescription == "No internet connection. Please check your network settings.")
    }

    @Test("Decoding failed error includes message")
    func test_whenDecodingFailedError_thenDescriptionIncludesMessage() {
        let error = NetworkError.decodingFailed("Invalid JSON")
        #expect(error.errorDescription?.contains("Invalid JSON") == true)
    }

    // MARK: - Status Code Mapping Tests

    @Test("200 status code returns nil error")
    func test_whenStatusCode200_thenReturnsNil() {
        let error = NetworkError.fromStatusCode(200)
        #expect(error == nil)
    }

    @Test("201 status code returns nil error")
    func test_whenStatusCode201_thenReturnsNil() {
        let error = NetworkError.fromStatusCode(201)
        #expect(error == nil)
    }

    @Test("401 status code returns unauthorized error")
    func test_whenStatusCode401_thenReturnsUnauthorized() {
        let error = NetworkError.fromStatusCode(401)
        #expect(error == .unauthorized)
    }

    @Test("403 status code returns forbidden error")
    func test_whenStatusCode403_thenReturnsForbidden() {
        let error = NetworkError.fromStatusCode(403)
        #expect(error == .forbidden)
    }

    @Test("404 status code returns not found error")
    func test_whenStatusCode404_thenReturnsNotFound() {
        let error = NetworkError.fromStatusCode(404)
        #expect(error == .notFound)
    }

    @Test("408 status code returns timeout error")
    func test_whenStatusCode408_thenReturnsTimeout() {
        let error = NetworkError.fromStatusCode(408)
        #expect(error == .timeout)
    }

    @Test("500 status code returns server error")
    func test_whenStatusCode500_thenReturnsServerError() {
        let error = NetworkError.fromStatusCode(500)
        #expect(error == .serverError(statusCode: 500))
    }

    @Test("503 status code returns server error")
    func test_whenStatusCode503_thenReturnsServerError() {
        let error = NetworkError.fromStatusCode(503)
        #expect(error == .serverError(statusCode: 503))
    }

    @Test("Other 4xx status codes return HTTP error")
    func test_whenStatusCode418_thenReturnsHttpError() {
        let error = NetworkError.fromStatusCode(418)
        #expect(error == .httpError(statusCode: 418, data: nil))
    }

    // MARK: - URL Error Mapping Tests

    @Test("URL timeout error maps to timeout")
    func test_whenURLErrorTimedOut_thenReturnsTimeout() {
        let urlError = URLError(.timedOut)
        let error = NetworkError.fromURLError(urlError)
        #expect(error == .timeout)
    }

    @Test("URL not connected error maps to no connection")
    func test_whenURLErrorNotConnected_thenReturnsNoConnection() {
        let urlError = URLError(.notConnectedToInternet)
        let error = NetworkError.fromURLError(urlError)
        #expect(error == .noConnection)
    }

    @Test("URL connection lost error maps to no connection")
    func test_whenURLErrorConnectionLost_thenReturnsNoConnection() {
        let urlError = URLError(.networkConnectionLost)
        let error = NetworkError.fromURLError(urlError)
        #expect(error == .noConnection)
    }

    @Test("URL cancelled error maps to cancelled")
    func test_whenURLErrorCancelled_thenReturnsCancelled() {
        let urlError = URLError(.cancelled)
        let error = NetworkError.fromURLError(urlError)
        #expect(error == .cancelled)
    }

    @Test("URL bad URL error maps to invalid URL")
    func test_whenURLErrorBadURL_thenReturnsInvalidURL() {
        let urlError = URLError(.badURL)
        let error = NetworkError.fromURLError(urlError)
        #expect(error == .invalidURL)
    }

    // MARK: - Equality Tests

    @Test("Same error types are equal")
    func test_whenSameErrorTypes_thenAreEqual() {
        #expect(NetworkError.invalidURL == NetworkError.invalidURL)
        #expect(NetworkError.unauthorized == NetworkError.unauthorized)
        #expect(NetworkError.serverError(statusCode: 500) == NetworkError.serverError(statusCode: 500))
    }

    @Test("Different error types are not equal")
    func test_whenDifferentErrorTypes_thenAreNotEqual() {
        #expect(NetworkError.invalidURL != NetworkError.unauthorized)
        #expect(NetworkError.serverError(statusCode: 500) != NetworkError.serverError(statusCode: 503))
    }
}
