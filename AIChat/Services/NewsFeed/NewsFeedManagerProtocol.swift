//
//  NewsFeedManagerProtocol.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

protocol NewsFeedManagerProtocol: Sendable {
    func fetchNews(category: String?) async throws -> NewsFeedResult
    func fetchTopHeadlines(country: String?) async throws -> NewsFeedResult
}

struct NewsFeedResult {
    let articles: [NewsArticle]
    let source: DataSource

    enum DataSource {
        case remote
        case local
    }
}
