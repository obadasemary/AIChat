//
//  RemoteNewsFeedServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

protocol RemoteNewsFeedServiceProtocol: Sendable {
    func fetchNews(category: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse
    func fetchTopHeadlines(country: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse
}

struct NewsFeedResponse {
    let articles: [NewsArticle]
    let totalResults: Int
}
