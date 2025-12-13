//
//  BookmarkManagerTests.swift
//  AIChat
//
//  Created by Claude Code on 12.12.2025.
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
}
