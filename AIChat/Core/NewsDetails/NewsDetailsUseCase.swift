//
//  NewsDetailsUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation

@MainActor
protocol NewsDetailsUseCaseProtocol {
    var bookmarkManager: BookmarkManager { get }
    func isArticleBookmarked(_ article: NewsArticle) -> Bool
    func addBookmark(_ article: NewsArticle)
    func removeBookmark(_ article: NewsArticle)
}

@MainActor
final class NewsDetailsUseCase: NewsDetailsUseCaseProtocol {

    // MARK: - Properties
    let bookmarkManager: BookmarkManager

    // MARK: - Initialization
    init(container: DependencyContainer) {
        // Try to resolve from container first, fallback to creating new instance
        // This allows tests to work without registering BookmarkManager
        if let resolvedManager = container.resolve(BookmarkManager.self) {
            self.bookmarkManager = resolvedManager
        } else {
            self.bookmarkManager = BookmarkManager()
        }
    }

    // MARK: - Public Methods
    func isArticleBookmarked(_ article: NewsArticle) -> Bool {
        bookmarkManager.isBookmarked(articleId: article.id)
    }

    func addBookmark(_ article: NewsArticle) {
        bookmarkManager.addBookmark(article)
    }

    func removeBookmark(_ article: NewsArticle) {
        bookmarkManager.removeBookmark(articleId: article.id)
    }
}
