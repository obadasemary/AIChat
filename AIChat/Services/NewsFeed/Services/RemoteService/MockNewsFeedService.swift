//
//  MockNewsFeedService.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

final class MockNewsFeedService: RemoteNewsFeedServiceProtocol, @unchecked Sendable {

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
        )
    ]

    func fetchNews(category: String?) async throws -> [NewsArticle] {
        if shouldFail {
            throw NewsFeedError.networkError
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        if let category = category {
            return mockArticles.filter { $0.category == category }
        }

        return mockArticles
    }

    func fetchTopHeadlines(country: String?) async throws -> [NewsArticle] {
        if shouldFail {
            throw NewsFeedError.networkError
        }

        try await Task.sleep(nanoseconds: 500_000_000)

        return mockArticles
    }
}
