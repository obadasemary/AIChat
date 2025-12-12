//
//  NewsDetailsUseCase.swift
//  AIChat
//
//  Created by Claude Code on 12.12.2025.
//

import Foundation

@MainActor
final class NewsDetailsUseCase: NewsDetailsUseCaseProtocol {

    // MARK: - Properties
    private let container: DependencyContainer

    // MARK: - Initialization
    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods
    func isArticleBookmarked(_ article: NewsArticle) -> Bool {
        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            return false
        }
        return bookmarkManager.isBookmarked(articleId: article.id)
    }

    func addBookmark(_ article: NewsArticle) {
        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            return
        }
        bookmarkManager.addBookmark(article)
    }

    func removeBookmark(_ article: NewsArticle) {
        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            return
        }
        bookmarkManager.removeBookmark(articleId: article.id)
    }
}
