//
//  NewsDetailsUseCaseProtocol.swift
//  AIChat
//
//  Created by Claude Code on 12.12.2025.
//

import Foundation

@MainActor
protocol NewsDetailsUseCaseProtocol {
    func isArticleBookmarked(_ article: NewsArticle) -> Bool
    func addBookmark(_ article: NewsArticle)
    func removeBookmark(_ article: NewsArticle)
}
