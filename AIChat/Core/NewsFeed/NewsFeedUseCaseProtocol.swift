//
//  NewsFeedUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.12.2025.
//

import Foundation

@MainActor
protocol NewsFeedUseCaseProtocol {
    func loadNews(category: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
    func loadTopHeadlines(country: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult
}
