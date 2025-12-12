//
//  BookmarkManager.swift
//  AIChat
//
//  Created by Claude Code on 12.12.2025.
//

import Foundation

@MainActor
@Observable
final class BookmarkManager {

    // MARK: - Properties
    private var bookmarkedArticles: Set<String> = []
    private let userDefaults = UserDefaults.standard
    private let bookmarksKey = "bookmarked_articles"

    // MARK: - Initialization
    init() {
        loadBookmarks()
    }

    // MARK: - Public Methods
    func isBookmarked(articleId: String) -> Bool {
        return bookmarkedArticles.contains(articleId)
    }

    func addBookmark(_ article: NewsArticle) {
        bookmarkedArticles.insert(article.id)
        saveBookmarks()
    }

    func removeBookmark(articleId: String) {
        bookmarkedArticles.remove(articleId)
        saveBookmarks()
    }

    func getAllBookmarks() -> Set<String> {
        return bookmarkedArticles
    }

    // MARK: - Private Methods
    private func loadBookmarks() {
        if let bookmarks = userDefaults.stringArray(forKey: bookmarksKey) {
            bookmarkedArticles = Set(bookmarks)
        }
    }

    private func saveBookmarks() {
        userDefaults.set(Array(bookmarkedArticles), forKey: bookmarksKey)
    }
}
