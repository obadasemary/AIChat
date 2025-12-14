//
//  BookmarkManagerTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct BookmarkManagerTests {

    // MARK: - Add Bookmark Tests

    @Test("Add Bookmark Adds Article ID")
    func testAddBookmarkAddsArticleID() {
        let manager = BookmarkManager()
        let article = NewsArticle.mock(title: "Test Article")

        // Clean state
        manager.removeBookmark(articleId: article.id)

        #expect(manager.isBookmarked(articleId: article.id) == false)

        manager.addBookmark(article)

        #expect(manager.isBookmarked(articleId: article.id) == true)
        #expect(manager.getAllBookmarks().contains(article.id))

        // Cleanup
        manager.removeBookmark(articleId: article.id)
    }

    @Test("Add Duplicate Bookmark Does Not Create Duplicate")
    func testAddDuplicateBookmarkDoesNotCreateDuplicate() {
        let manager = BookmarkManager()
        let article = NewsArticle.mock(title: "Duplicate Article")

        // Clean state
        manager.removeBookmark(articleId: article.id)

        let initialCount = manager.getAllBookmarks().count

        manager.addBookmark(article)
        manager.addBookmark(article)

        #expect(manager.getAllBookmarks().count == initialCount + 1)

        // Cleanup
        manager.removeBookmark(articleId: article.id)
    }

    // MARK: - Remove Bookmark Tests

    @Test("Remove Bookmark Removes Article ID")
    func testRemoveBookmarkRemovesArticleID() {
        let manager = BookmarkManager()
        let article = NewsArticle.mock(title: "Remove Test")

        manager.addBookmark(article)
        #expect(manager.isBookmarked(articleId: article.id) == true)

        manager.removeBookmark(articleId: article.id)
        #expect(manager.isBookmarked(articleId: article.id) == false)
        #expect(manager.getAllBookmarks().contains(article.id) == false)
    }

    @Test("Remove Non-Existent Bookmark Does Not Crash")
    func testRemoveNonExistentBookmarkDoesNotCrash() {
        let manager = BookmarkManager()

        // Should not crash
        manager.removeBookmark(articleId: "non-existent-id-12345")

        // Test passes if no crash occurs
        #expect(true)
    }

    // MARK: - Check Bookmark Tests

    @Test("Is Bookmarked Returns Correct Status")
    func testIsBookmarkedReturnsCorrectStatus() {
        let manager = BookmarkManager()
        let bookmarkedArticle = NewsArticle.mock(title: "Bookmarked")
        let notBookmarkedArticle = NewsArticle.mock(title: "Not Bookmarked")

        // Clean state
        manager.removeBookmark(articleId: bookmarkedArticle.id)
        manager.removeBookmark(articleId: notBookmarkedArticle.id)

        manager.addBookmark(bookmarkedArticle)

        #expect(manager.isBookmarked(articleId: bookmarkedArticle.id) == true)
        #expect(manager.isBookmarked(articleId: notBookmarkedArticle.id) == false)

        // Cleanup
        manager.removeBookmark(articleId: bookmarkedArticle.id)
    }

    // MARK: - Toggle Bookmark Tests

    @Test("Toggle Bookmark Lifecycle")
    func testToggleBookmarkLifecycle() {
        let manager = BookmarkManager()
        let article = NewsArticle.mock(title: "Toggle Test")

        // Clean state
        manager.removeBookmark(articleId: article.id)

        // Start not bookmarked
        #expect(manager.isBookmarked(articleId: article.id) == false)

        // Add bookmark
        manager.addBookmark(article)
        #expect(manager.isBookmarked(articleId: article.id) == true)

        // Remove bookmark
        manager.removeBookmark(articleId: article.id)
        #expect(manager.isBookmarked(articleId: article.id) == false)

        // Add again
        manager.addBookmark(article)
        #expect(manager.isBookmarked(articleId: article.id) == true)

        // Cleanup
        manager.removeBookmark(articleId: article.id)
    }

    // MARK: - Get Bookmarked Articles Tests

    @Test("Get Bookmarked Articles Returns Empty Array Initially")
    func testGetBookmarkedArticlesReturnsEmptyArrayInitially() {
        let manager = BookmarkManager()

        let articles = manager.getBookmarkedArticles()

        #expect(articles.isEmpty)
    }

    @Test("Get Bookmarked Articles Returns All Bookmarked Articles")
    func testGetBookmarkedArticlesReturnsAllBookmarkedArticles() {
        let manager = BookmarkManager()
        let article1 = NewsArticle.mock(id: "test-1", title: "Article 1")
        let article2 = NewsArticle.mock(id: "test-2", title: "Article 2")
        let article3 = NewsArticle.mock(id: "test-3", title: "Article 3")

        // Clean state
        manager.removeBookmark(articleId: article1.id)
        manager.removeBookmark(articleId: article2.id)
        manager.removeBookmark(articleId: article3.id)

        // Add bookmarks
        manager.addBookmark(article1)
        manager.addBookmark(article2)
        manager.addBookmark(article3)

        let articles = manager.getBookmarkedArticles()

        #expect(articles.count == 3)
        #expect(articles.contains(where: { $0.id == article1.id }))
        #expect(articles.contains(where: { $0.id == article2.id }))
        #expect(articles.contains(where: { $0.id == article3.id }))

        // Cleanup
        manager.removeBookmark(articleId: article1.id)
        manager.removeBookmark(articleId: article2.id)
        manager.removeBookmark(articleId: article3.id)
    }

    @Test("Get Bookmarked Articles Returns Articles Sorted by Date")
    func testGetBookmarkedArticlesReturnsArticlesSortedByDate() {
        let manager = BookmarkManager()
        let now = Date()
        let oldArticle = NewsArticle.mock(
            id: "old",
            title: "Old Article",
            publishedAt: now.addingTimeInterval(-86400) // 1 day ago
        )
        let newArticle = NewsArticle.mock(
            id: "new",
            title: "New Article",
            publishedAt: now
        )

        // Clean state
        manager.removeBookmark(articleId: oldArticle.id)
        manager.removeBookmark(articleId: newArticle.id)

        // Add in reverse order
        manager.addBookmark(oldArticle)
        manager.addBookmark(newArticle)

        let articles = manager.getBookmarkedArticles()

        // Should be sorted newest first
        #expect(articles.first?.id == newArticle.id)
        #expect(articles.last?.id == oldArticle.id)

        // Cleanup
        manager.removeBookmark(articleId: oldArticle.id)
        manager.removeBookmark(articleId: newArticle.id)
    }

    @Test("Get Bookmarked Articles After Removing One")
    func testGetBookmarkedArticlesAfterRemovingOne() {
        let manager = BookmarkManager()
        let article1 = NewsArticle.mock(id: "keep-1", title: "Keep 1")
        let article2 = NewsArticle.mock(id: "remove", title: "Remove")
        let article3 = NewsArticle.mock(id: "keep-2", title: "Keep 2")

        // Clean state
        manager.removeBookmark(articleId: article1.id)
        manager.removeBookmark(articleId: article2.id)
        manager.removeBookmark(articleId: article3.id)

        // Add all
        manager.addBookmark(article1)
        manager.addBookmark(article2)
        manager.addBookmark(article3)

        #expect(manager.getBookmarkedArticles().count == 3)

        // Remove one
        manager.removeBookmark(articleId: article2.id)

        let articles = manager.getBookmarkedArticles()
        #expect(articles.count == 2)
        #expect(articles.contains(where: { $0.id == article1.id }))
        #expect(articles.contains(where: { $0.id == article3.id }))
        #expect(articles.contains(where: { $0.id == article2.id }) == false)

        // Cleanup
        manager.removeBookmark(articleId: article1.id)
        manager.removeBookmark(articleId: article3.id)
    }
}
