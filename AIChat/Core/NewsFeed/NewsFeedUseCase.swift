//
//  NewsFeedUseCase.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

@MainActor
final class NewsFeedUseCase {

    private let newsFeedManager: NewsFeedManager

    init(container: DependencyContainer) {
        // swiftlint:disable:next force_unwrapping
        self.newsFeedManager = container.resolve(NewsFeedManager.self)!
    }

    func loadNews(category: String? = nil) async throws -> NewsFeedResult {
        try await newsFeedManager.fetchNews(category: category)
    }

    func loadTopHeadlines(country: String? = nil) async throws -> NewsFeedResult {
        try await newsFeedManager.fetchTopHeadlines(country: country)
    }
}
