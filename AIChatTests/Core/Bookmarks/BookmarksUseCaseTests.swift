//
//  BookmarksUseCaseTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct BookmarksUseCaseTests {

    // MARK: - Get Bookmarked Articles Tests

    @Test("Get Bookmarked Articles Returns Empty Array When No Bookmarks")
    func testGetBookmarkedArticlesReturnsEmptyArrayWhenNoBookmarks() {
        let container = createTestContainer()
        let useCase = BookmarksUseCase(container: container)

        let articles = useCase.getBookmarkedArticles()

        #expect(articles.isEmpty)
    }

    @Test("Get Bookmarked Articles Returns All Bookmarked Articles")
    func testGetBookmarkedArticlesReturnsAllBookmarkedArticles() {
        let container = createTestContainer()
        let bookmarkManager = container.resolve(BookmarkManager.self)!

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        let article3 = NewsArticle.mock(title: "Article 3")

        bookmarkManager.addBookmark(article1)
        bookmarkManager.addBookmark(article2)
        bookmarkManager.addBookmark(article3)

        let useCase = BookmarksUseCase(container: container)
        let articles = useCase.getBookmarkedArticles()

        #expect(articles.count == 3)
        #expect(articles.contains { $0.id == article1.id })
        #expect(articles.contains { $0.id == article2.id })
        #expect(articles.contains { $0.id == article3.id })
    }

    @Test("Get Bookmarked Articles Returns Correct Data")
    func testGetBookmarkedArticlesReturnsCorrectData() {
        let container = createTestContainer()
        let bookmarkManager = container.resolve(BookmarkManager.self)!

        let article = NewsArticle.mock(
            title: "Breaking News",
            description: "Important news description",
            source: NewsSource(id: "bbc", name: "BBC News")
        )

        bookmarkManager.addBookmark(article)

        let useCase = BookmarksUseCase(container: container)
        let articles = useCase.getBookmarkedArticles()

        #expect(articles.count == 1)
        #expect(articles[0].title == "Breaking News")
        #expect(articles[0].description == "Important news description")
        #expect(articles[0].source.name == "BBC News")
    }

    // MARK: - Remove Bookmark Tests

    @Test("Remove Bookmark Removes Article from Manager")
    func testRemoveBookmarkRemovesArticleFromManager() {
        let container = createTestContainer()
        let bookmarkManager = container.resolve(BookmarkManager.self)!
        let useCase = BookmarksUseCase(container: container)

        let article = NewsArticle.mock(title: "Remove Test")
        bookmarkManager.addBookmark(article)

        #expect(useCase.getBookmarkedArticles().count == 1)

        useCase.removeBookmark(articleId: article.id)

        #expect(useCase.getBookmarkedArticles().isEmpty)
        #expect(bookmarkManager.isBookmarked(articleId: article.id) == false)
    }

    @Test("Remove Bookmark Removes Only Specified Article")
    func testRemoveBookmarkRemovesOnlySpecifiedArticle() {
        let container = createTestContainer()
        let bookmarkManager = container.resolve(BookmarkManager.self)!
        let useCase = BookmarksUseCase(container: container)

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        let article3 = NewsArticle.mock(title: "Article 3")

        bookmarkManager.addBookmark(article1)
        bookmarkManager.addBookmark(article2)
        bookmarkManager.addBookmark(article3)

        useCase.removeBookmark(articleId: article2.id)

        let articles = useCase.getBookmarkedArticles()
        #expect(articles.count == 2)
        #expect(articles.contains { $0.id == article1.id })
        #expect(articles.contains { $0.id == article3.id })
        #expect(!articles.contains { $0.id == article2.id })
    }

    @Test("Remove Bookmark Non-Existent Article Does Not Crash")
    func testRemoveBookmarkNonExistentArticleDoesNotCrash() {
        let container = createTestContainer()
        let useCase = BookmarksUseCase(container: container)

        // Should not crash
        useCase.removeBookmark(articleId: "non-existent-id")

        #expect(useCase.getBookmarkedArticles().isEmpty)
    }

    // MARK: - Track Event Tests

    @Test("Track Event Does Not Crash")
    func testTrackEventDoesNotCrash() {
        let container = createTestContainer()
        let useCase = BookmarksUseCase(container: container)

        let event = MockLoggableEvent(name: "test_event")

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    @Test("Track Event With Parameters Does Not Crash")
    func testTrackEventWithParametersDoesNotCrash() {
        let container = createTestContainer()
        let useCase = BookmarksUseCase(container: container)

        let parameters: [String: Any] = ["key1": "value1", "key2": 42]
        let event = MockLoggableEvent(name: "test_event", parameters: parameters)

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    // MARK: - Integration Tests

    @Test("UseCase Reflects Changes Made to BookmarkManager")
    func testUseCaseReflectsChangesMadeToBookmarkManager() {
        let container = createTestContainer()
        let bookmarkManager = container.resolve(BookmarkManager.self)!
        let useCase = BookmarksUseCase(container: container)

        let article = NewsArticle.mock(title: "Test Article")

        // Initially empty
        #expect(useCase.getBookmarkedArticles().isEmpty)

        // Add via manager
        bookmarkManager.addBookmark(article)
        #expect(useCase.getBookmarkedArticles().count == 1)

        // Remove via use case
        useCase.removeBookmark(articleId: article.id)
        #expect(useCase.getBookmarkedArticles().isEmpty)
        #expect(bookmarkManager.isBookmarked(articleId: article.id) == false)
    }

    // MARK: - Helper Methods

    private func createTestContainer() -> DependencyContainer {
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "bookmarked_articles")
        UserDefaults.standard.removeObject(forKey: "bookmarked_articles_data")

        let container = DependencyContainer()
        let bookmarkManager = BookmarkManager()
        let logManager = LogManager(services: [MockLogService()])
        container.register(BookmarkManager.self, bookmarkManager)
        container.register(LogManager.self, logManager)
        return container
    }
}

// MARK: - Mock LoggableEvent

struct MockLoggableEvent: LoggableEvent {
    let name: String
    let parameters: [String: Any]?

    var eventName: String { name }
    var type: LogType { .analytic }

    init(name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
    }
}
