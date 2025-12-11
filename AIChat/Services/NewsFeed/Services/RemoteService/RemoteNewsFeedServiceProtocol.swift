//
//  RemoteNewsFeedServiceProtocol.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

protocol RemoteNewsFeedServiceProtocol: Sendable {
    func fetchNews(category: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse
    func fetchTopHeadlines(country: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse
}

struct NewsFeedResponse {
    let articles: [NewsArticle]
    let totalResults: Int
}
