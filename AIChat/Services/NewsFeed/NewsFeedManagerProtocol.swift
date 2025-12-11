//
//  NewsFeedManagerProtocol.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

protocol NewsFeedManagerProtocol: Sendable {
    func fetchNews(category: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
    func fetchTopHeadlines(country: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
}

struct NewsFeedResult {
    let articles: [NewsArticle]
    let source: DataSource

    enum DataSource {
        case remote
        case local
    }
}
