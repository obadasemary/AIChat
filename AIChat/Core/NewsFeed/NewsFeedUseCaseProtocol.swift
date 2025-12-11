//
//  NewsFeedUseCaseProtocol.swift
//  AIChat
//
//  Created by Claude on 11.12.2025.
//

import Foundation

@MainActor
protocol NewsFeedUseCaseProtocol {
    func loadNews(category: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
    func loadTopHeadlines(country: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
}
