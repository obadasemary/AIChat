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
        bookmarkManager = container.resolve(BookmarkManager.self)!
        logManager = container.resolve(LogManager.self)!
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
