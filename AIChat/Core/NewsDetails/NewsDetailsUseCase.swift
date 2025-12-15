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
@Observable
final class NewsDetailsUseCase: NewsDetailsUseCaseProtocol {

    // MARK: - Properties
    let bookmarkManager: BookmarkManager

    // MARK: - Initialization
    init(container: DependencyContainer) {
        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            fatalError("Required dependencies not registered in container")
        }
        self.bookmarkManager = bookmarkManager
    }

    // MARK: - Public Methods
    func isArticleBookmarked(_ article: NewsArticle) -> Bool {
        return bookmarkManager.isBookmarked(articleId: article.id)
    }

    func addBookmark(_ article: NewsArticle) {
        bookmarkManager.addBookmark(article)
    }

    func removeBookmark(_ article: NewsArticle) {
        bookmarkManager.removeBookmark(articleId: article.id)
    }
}
