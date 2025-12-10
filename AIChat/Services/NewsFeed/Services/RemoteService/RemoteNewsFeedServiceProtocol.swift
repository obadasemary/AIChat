//
//  RemoteNewsFeedServiceProtocol.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

protocol RemoteNewsFeedServiceProtocol: Sendable {
    func fetchNews(category: String?) async throws -> [NewsArticle]
    func fetchTopHeadlines(country: String?) async throws -> [NewsArticle]
}
