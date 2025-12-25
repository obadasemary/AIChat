//
//  NewsDetailsInteractorTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct NewsDetailsInteractorTests {

    // MARK: - Is Article Bookmarked Tests

    @Test("Is Article Bookmarked Returns False When Not Bookmarked")
    func testIsArticleBookmarkedReturnsFalseWhenNotBookmarked() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "Test Article")

        let isBookmarked = useCase.isArticleBookmarked(article)

        #expect(isBookmarked == false)
    }

    @Test("Is Article Bookmarked Returns True When Bookmarked")
    func testIsArticleBookmarkedReturnsTrueWhenBookmarked() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "Bookmarked Article")

        useCase.addBookmark(article)

        let isBookmarked = useCase.isArticleBookmarked(article)

        #expect(isBookmarked == true)
    }

    // MARK: - Add Bookmark Tests

    @Test("Add Bookmark Saves Article to Manager")
    func testAddBookmarkSavesArticleToManager() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "New Bookmark")

        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            Issue.record("BookmarkManager not found in container")
            return
        }

        #expect(bookmarkManager.isBookmarked(articleId: article.id) == false)

        useCase.addBookmark(article)

        #expect(bookmarkManager.isBookmarked(articleId: article.id) == true)
    }

    @Test("Add Bookmark Multiple Articles")
    func testAddBookmarkMultipleArticles() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        let article3 = NewsArticle.mock(title: "Article 3")

        useCase.addBookmark(article1)
        useCase.addBookmark(article2)
        useCase.addBookmark(article3)

        #expect(useCase.isArticleBookmarked(article1) == true)
        #expect(useCase.isArticleBookmarked(article2) == true)
        #expect(useCase.isArticleBookmarked(article3) == true)
    }

    // MARK: - Remove Bookmark Tests

    @Test("Remove Bookmark Removes Article from Manager")
    func testRemoveBookmarkRemovesArticleFromManager() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "Remove Test")

        useCase.addBookmark(article)
        #expect(useCase.isArticleBookmarked(article) == true)

        useCase.removeBookmark(article)

        #expect(useCase.isArticleBookmarked(article) == false)
    }

    @Test("Remove Bookmark Non-Existent Article Does Not Crash")
    func testRemoveBookmarkNonExistentArticleDoesNotCrash() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "Never Bookmarked")

        // Should not crash
        useCase.removeBookmark(article)

        #expect(useCase.isArticleBookmarked(article) == false)
    }

    @Test("Remove Bookmark After Adding and Removing")
    func testRemoveBookmarkAfterAddingAndRemoving() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "Toggle Test")

        // Add
        useCase.addBookmark(article)
        #expect(useCase.isArticleBookmarked(article) == true)

        // Remove
        useCase.removeBookmark(article)
        #expect(useCase.isArticleBookmarked(article) == false)

        // Add again
        useCase.addBookmark(article)
        #expect(useCase.isArticleBookmarked(article) == true)
    }

    // MARK: - Container Integration Tests

    @Test("UseCase Works with Nil BookmarkManager")
    func testUseCaseWorksWithNilBookmarkManager() {
        let container = DependencyContainer()
        // Don't register BookmarkManager

        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "Test Article")

        // Should not crash
        let isBookmarked = useCase.isArticleBookmarked(article)
        #expect(isBookmarked == false)

        useCase.addBookmark(article)
        useCase.removeBookmark(article)
    }

    @Test("UseCase Uses Registered BookmarkManager")
    func testUseCaseUsesRegisteredBookmarkManager() {
        let container = createTestContainer()
        let useCase = NewsDetailsInteractor(container: container)
        let article = NewsArticle.mock(title: "Registered Manager Test")

        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            Issue.record("BookmarkManager not found in container")
            return
        }

        // Add via use case
        useCase.addBookmark(article)

        // Check directly in manager
        #expect(bookmarkManager.isBookmarked(articleId: article.id) == true)

        // Remove via use case
        useCase.removeBookmark(article)

        // Check directly in manager
        #expect(bookmarkManager.isBookmarked(articleId: article.id) == false)
    }

    // MARK: - Helper Methods

    private func createTestContainer() -> DependencyContainer {
        let container = DependencyContainer()
        // Use in-memory storage for faster, more reliable tests
        let bookmarkManager = BookmarkManager(isStoredInMemoryOnly: true)
        container.register(BookmarkManager.self, bookmarkManager)
        return container
    }
}
