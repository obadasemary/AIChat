//
//  MockLocalNewsFeedService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

final class MockLocalNewsFeedService: LocalNewsFeedServiceProtocol, @unchecked Sendable {

    private var cachedArticles: [NewsArticle] = []

    func saveNews(_ articles: [NewsArticle]) throws {
        cachedArticles = articles
    }

    func fetchCachedNews() throws -> [NewsArticle] {
        return cachedArticles
    }

    func clearCache() throws {
        cachedArticles = []
    }
}
