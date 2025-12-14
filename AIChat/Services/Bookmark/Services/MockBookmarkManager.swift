//
//  MockBookmarkManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import Foundation

@MainActor
@Observable
final class MockBookmarkManager: BookmarkManagerProtocol {

    // MARK: - Properties
    private var bookmarkedArticles: [String: NewsArticle] = [:]

    // MARK: - Initialization
    init(initialBookmarks: [NewsArticle] = []) {
        initialBookmarks.forEach { article in
            bookmarkedArticles[article.id] = article
        }
    }

    // MARK: - Public Methods
    func isBookmarked(articleId: String) -> Bool {
        return bookmarkedArticles[articleId] != nil
    }

    func addBookmark(_ article: NewsArticle) {
        bookmarkedArticles[article.id] = article
    }

    func removeBookmark(articleId: String) {
        bookmarkedArticles.removeValue(forKey: articleId)
    }

    func getAllBookmarks() -> Set<String> {
        return Set(bookmarkedArticles.keys)
    }

    func getBookmarkedArticles() -> [NewsArticle] {
        return Array(bookmarkedArticles.values).sorted { article1, article2 in
            article1.publishedAt > article2.publishedAt
        }
    }
}
