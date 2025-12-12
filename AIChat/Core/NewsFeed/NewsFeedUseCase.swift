//
//  NewsFeedUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

@MainActor
final class NewsFeedUseCase: NewsFeedUseCaseProtocol {

    private let newsFeedManager: NewsFeedManagerProtocol

    init(container: DependencyContainer) {
        // swiftlint:disable:next force_unwrapping
        self.newsFeedManager = container.resolve(NewsFeedManager.self)!
    }

    func loadNews(category: String? = nil, language: String? = nil, page: Int, pageSize: Int) async throws -> NewsFeedResult {
        try await newsFeedManager.fetchNews(category: category, language: language, page: page, pageSize: pageSize)
    }

    func loadTopHeadlines(country: String? = nil, language: String? = nil, page: Int, pageSize: Int) async throws -> NewsFeedResult {
        try await newsFeedManager.fetchTopHeadlines(country: country, language: language, page: page, pageSize: pageSize)
    }
}
