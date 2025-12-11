//
//  MockRemoteNewsFeedService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

final class MockRemoteNewsFeedService: RemoteNewsFeedServiceProtocol, @unchecked Sendable {

    var shouldFail: Bool = false
    var mockArticles: [NewsArticle] = [
        .mock(
            title: "SwiftUI 6.0 Released",
            description: "Apple announces major update to SwiftUI",
            category: "Technology"
        ),
        .mock(
            title: "iOS 19 Beta Available",
            description: "New iOS version brings exciting features",
            category: "Technology"
        ),
        .mock(
            title: "AI Advances in 2025",
            description: "Machine learning reaches new milestones",
            category: "Science"
        ),
        .mock(title: "Article 4", description: "Desc 4", category: "General"),
        .mock(title: "Article 5", description: "Desc 5", category: "General"),
        .mock(title: "Article 6", description: "Desc 6", category: "General"),
        .mock(title: "Article 7", description: "Desc 7", category: "General"),
        .mock(title: "Article 8", description: "Desc 8", category: "General"),
        .mock(title: "Article 9", description: "Desc 9", category: "General"),
        .mock(title: "Article 10", description: "Desc 10", category: "General"),
        .mock(title: "Article 11", description: "Desc 11", category: "General"),
        .mock(title: "Article 12", description: "Desc 12", category: "General"),
        .mock(title: "Article 13", description: "Desc 13", category: "General")
    ]

    func fetchNews(category: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        if shouldFail {
            throw NewsFeedError.networkError
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        var filteredArticles = mockArticles
        if let category = category {
            filteredArticles = mockArticles.filter { $0.category == category }
        }

        return paginateArticles(filteredArticles, page: page, pageSize: pageSize)
    }

    func fetchTopHeadlines(country: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        if shouldFail {
            throw NewsFeedError.networkError
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        return paginateArticles(mockArticles, page: page, pageSize: pageSize)
    }

    private func paginateArticles(_ articles: [NewsArticle], page: Int, pageSize: Int) -> NewsFeedResponse {
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, articles.count)

        let paginatedArticles: [NewsArticle]
        if startIndex < articles.count {
            paginatedArticles = Array(articles[startIndex..<endIndex])
        } else {
            paginatedArticles = []
        }

        return NewsFeedResponse(
            articles: paginatedArticles,
            totalResults: articles.count
        )
    }
}
