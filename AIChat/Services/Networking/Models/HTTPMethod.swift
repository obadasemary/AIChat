//
//  HTTPMethod.swift
//  AIChat
//
//  Created on 2026-02-02.
//

import Foundation

/// HTTP methods supported by the networking layer
enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
}
