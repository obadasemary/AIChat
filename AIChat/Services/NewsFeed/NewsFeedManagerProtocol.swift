//
//  NewsFeedManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

protocol NewsFeedManagerProtocol: Sendable {
    func fetchNews(category: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
    func fetchTopHeadlines(country: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
}

struct NewsFeedResult {
    let articles: [NewsArticle]
    let source: DataSource
    let totalResults: Int?

    enum DataSource {
        case remote
        case local
    }
}
