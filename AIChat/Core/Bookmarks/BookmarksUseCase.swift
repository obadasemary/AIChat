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
final class BookmarksUseCase: BookmarksUseCaseProtocol {

    // MARK: - Properties
    private let container: DependencyContainer

    private var bookmarkManager: BookmarkManagerProtocol {
        guard let manager = container.resolve(BookmarkManagerProtocol.self) else {
            fatalError("BookmarkManager not registered in container")
        }
        return manager
    }

    private var logManager: LogManager {
        guard let manager = container.resolve(LogManager.self) else {
            fatalError("LogManager not registered in container")
        }
        return manager
    }

    // MARK: - Initialization
    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods
    func getBookmarkedArticles() -> [NewsArticle] {
        return bookmarkManager.getBookmarkedArticles()
    }

    func removeBookmark(articleId: String) {
        bookmarkManager.removeBookmark(articleId: articleId)
    }

    func trackEvent(event: any LoggableEvent) {
        logManager.log(event: event)
    }
}
