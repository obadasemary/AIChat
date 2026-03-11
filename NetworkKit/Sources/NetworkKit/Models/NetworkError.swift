// NetworkError.swift
// NetworkKit

import Foundation

/// Typed errors that can be produced by the networking layer.
///
/// Conforms to `LocalizedError` so every case surfaces a human-readable
/// description without requiring the caller to switch manually.
public enum NetworkError: LocalizedError, Equatable, Sendable {
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

    // MARK: - LocalizedError

    public var errorDescription: String? {
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

    // MARK: - Factory helpers

    /// Maps an HTTP status code to a typed `NetworkError`, or returns `nil`
    /// for any 2xx success code.
    public static func fromStatusCode(_ statusCode: Int, data: Data? = nil) -> NetworkError? {
        switch statusCode {
        case 200...299: return nil
        case 401:       return .unauthorized
        case 403:       return .forbidden
        case 404:       return .notFound
        case 408:       return .timeout
        case 500...599: return .serverError(statusCode: statusCode)
        default:        return .httpError(statusCode: statusCode, data: data)
        }
    }

    /// Maps a `URLError` to the closest `NetworkError` equivalent.
    public static func fromURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .timedOut:                                  return .timeout
        case .notConnectedToInternet, .networkConnectionLost: return .noConnection
        case .cancelled:                                 return .cancelled
        case .badURL:                                    return .invalidURL
        default:                                         return .unknown(error.localizedDescription)
        }
    }

    // MARK: - Equatable

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
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
        case (.decodingFailed(let l), .decodingFailed(let r)):   return l == r
        case (.encodingFailed(let l), .encodingFailed(let r)):   return l == r
        case (.httpError(let lc, _), .httpError(let rc, _)):     return lc == rc
        case (.serverError(let lc), .serverError(let rc)):       return lc == rc
        case (.unknown(let l), .unknown(let r)):                 return l == r
        default:                                                  return false
        }
    }
}
