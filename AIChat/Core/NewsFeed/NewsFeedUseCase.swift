//
//  NewsFeedUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

@MainActor
protocol NewsFeedUseCaseProtocol {
    func loadNews(
        category: String?,
        language: String?,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult
    
    func loadTopHeadlines(
        country: String?,
        language: String?,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult
}

@MainActor
final class NewsFeedUseCase: NewsFeedUseCaseProtocol {

    private let newsFeedManager: NewsFeedManagerProtocol

    init(container: DependencyContainer) {
        guard let newsFeedManager = container.resolve(NewsFeedManager.self) else {
            fatalError("Failed to resolve NewsFeedManager for NewsFeedUseCase")
        }
        self.newsFeedManager = newsFeedManager
    }

    func loadNews(
        category: String? = nil,
        language: String? = nil,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult {
        try await newsFeedManager
            .fetchNews(
                category: category,
                language: language,
                page: page,
                pageSize: pageSize
            )
    }

    func loadTopHeadlines(
        country: String? = nil,
        language: String? = nil,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult {
        try await newsFeedManager
            .fetchTopHeadlines(
                country: country,
                language: language,
                page: page,
                pageSize: pageSize
            )
    }
}
