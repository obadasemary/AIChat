//
//  BookmarksUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import Foundation

@MainActor
protocol BookmarksUseCaseProtocol {
    func getBookmarkedArticles() -> [NewsArticle]
    func removeBookmark(articleId: String)
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class BookmarksUseCase {

    // MARK: - Properties
    private let bookmarkManager: BookmarkManager
    private let logManager: LogManager

    init(container: DependencyContainer) {
        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            preconditionFailure("Failed to resolve BookmarkManager for BookmarksUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for BookmarksUseCase")
        }
        self.bookmarkManager = bookmarkManager
        self.logManager = logManager
    }
}

@MainActor
extension BookmarksUseCase: BookmarksUseCaseProtocol {

    func getBookmarkedArticles() -> [NewsArticle] {
        return bookmarkManager.getBookmarkedArticles()
    }

    func removeBookmark(articleId: String) {
        bookmarkManager.removeBookmark(articleId: articleId)
    }

    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
