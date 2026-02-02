//
//  NetworkError.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// Errors that can occur during network operations
enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case noData
    case decodingFailed(String)
    case encodingFailed(String)
    case httpError(statusCode: Int, data: Data?)
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case timeout
    case noConnection
    case cancelled
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidRequest:
            return "The request is invalid."
        case .invalidResponse:
            return "The server response is invalid."
        case .noData:
            return "No data received from the server."
        case .decodingFailed(let message):
            return "Failed to decode response: \(message)"
        case .encodingFailed(let message):
            return "Failed to encode request: \(message)"
        case .httpError(let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        case .unauthorized:
            return "Authentication required. Please sign in again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .timeout:
            return "The request timed out. Please try again."
        case .noConnection:
            return "No internet connection. Please check your network settings."
        case .cancelled:
            return "The request was cancelled."
        case .unknown(let message):
            return "An unknown error occurred: \(message)"
        }
    }

    /// Creates a NetworkError from an HTTP status code
    static func fromStatusCode(_ statusCode: Int, data: Data? = nil) -> NetworkError? {
        switch statusCode {
        case 200...299:
            return nil
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 408:
            return .timeout
        case 500...599:
            return .serverError(statusCode: statusCode)
        default:
            return .httpError(statusCode: statusCode, data: data)
        }
    }

    /// Creates a NetworkError from a URL error
    static func fromURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        case .cancelled:
            return .cancelled
        case .badURL:
            return .invalidURL
        default:
            return .unknown(error.localizedDescription)
        }
    }

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidRequest, .invalidRequest),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.timeout, .timeout),
             (.noConnection, .noConnection),
             (.cancelled, .cancelled):
            return true
        case (.decodingFailed(let lhsMsg), .decodingFailed(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.encodingFailed(let lhsMsg), .encodingFailed(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.httpError(let lhsCode, _), .httpError(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}
