//
//  NewsDetailsPresenterTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation
import Testing
import Observation
@testable import AIChat

@MainActor
struct NewsDetailsPresenterTests {

    // MARK: - Initialization Tests

    @Test("ViewModel Initializes With Article")
    func testViewModelInitializesWithArticle() {
        let article = NewsArticle.mock(title: "Test Article")
        let mockUseCase = MockNewsDetailsInteractor()

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.article.id == article.id)
        #expect(presenter.article.title == article.title)
    }

    @Test("ViewModel Loads Bookmark Status on Init")
    func testViewModelLoadsBookmarkStatusOnInit() {
        let article = NewsArticle.mock(title: "Bookmarked Article")
        let mockUseCase = MockNewsDetailsInteractor()

        // Pre-bookmark the article
        mockUseCase.addBookmark(article)

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.isBookmarked == true)
    }

    @Test("ViewModel Shows Not Bookmarked When Article Not Bookmarked")
    func testViewModelShowsNotBookmarkedWhenArticleNotBookmarked() {
        let article = NewsArticle.mock(title: "Not Bookmarked Article")
        let mockUseCase = MockNewsDetailsInteractor()

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.isBookmarked == false)
    }

    // MARK: - Toggle Bookmark Tests

    @Test("Toggle Bookmark Adds Bookmark When Not Bookmarked")
    func testToggleBookmarkAddsBookmarkWhenNotBookmarked() {
        let article = NewsArticle.mock(title: "Toggle Add Test")
        let mockUseCase = MockNewsDetailsInteractor()

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.isBookmarked == false)

        presenter.toggleBookmark()

        #expect(presenter.isBookmarked == true)
        #expect(mockUseCase.isArticleBookmarked(article) == true)
    }

    @Test("Toggle Bookmark Removes Bookmark When Bookmarked")
    func testToggleBookmarkRemovesBookmarkWhenBookmarked() {
        let article = NewsArticle.mock(title: "Toggle Remove Test")
        let mockUseCase = MockNewsDetailsInteractor()

        // Pre-bookmark the article
        mockUseCase.addBookmark(article)

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.isBookmarked == true)

        presenter.toggleBookmark()

        #expect(presenter.isBookmarked == false)
        #expect(mockUseCase.isArticleBookmarked(article) == false)
    }

    @Test("Toggle Bookmark Multiple Times")
    func testToggleBookmarkMultipleTimes() {
        let article = NewsArticle.mock(title: "Toggle Multiple Test")
        let mockUseCase = MockNewsDetailsInteractor()

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.isBookmarked == false)

        // Toggle on
        presenter.toggleBookmark()
        #expect(presenter.isBookmarked == true)

        // Toggle off
        presenter.toggleBookmark()
        #expect(presenter.isBookmarked == false)

        // Toggle on again
        presenter.toggleBookmark()
        #expect(presenter.isBookmarked == true)
    }

    // MARK: - Article Data Tests

    @Test("ViewModel Preserves Article Title")
    func testViewModelPreservesArticleTitle() {
        let article = NewsArticle.mock(
            title: "Important Breaking News",
            description: "This is a test description"
        )
        let mockUseCase = MockNewsDetailsInteractor()

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.article.title == "Important Breaking News")
    }

    @Test("ViewModel Preserves Article Content")
    func testViewModelPreservesArticleContent() {
        let article = NewsArticle.mock(
            title: "News Article",
            description: "Description text",
            content: "Full article content here"
        )
        let mockUseCase = MockNewsDetailsInteractor()

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.article.content == "Full article content here")
        #expect(presenter.article.description == "Description text")
    }

    @Test("ViewModel Preserves Article Source")
    func testViewModelPreservesArticleSource() {
        let article = NewsArticle.mock(
            title: "News Article",
            source: NewsSource(id: "bbc", name: "BBC News")
        )
        let mockUseCase = MockNewsDetailsInteractor()

        let presenter = NewsDetailsPresenter(
            article: article,
            newsDetailsInteractor: mockUseCase,
            router: MockNewsDetailsRouter()
        )

        #expect(presenter.article.source.name == "BBC News")
    }
}

// MARK: - Mock NewsDetailsUseCase

@MainActor
final class MockNewsDetailsInteractor: NewsDetailsInteractorProtocol {

    let bookmarkManager: BookmarkManager

    init() {
        // Use in-memory storage for faster, more reliable tests
        self.bookmarkManager = BookmarkManager(isStoredInMemoryOnly: true)
    }

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

@MainActor
final class MockNewsDetailsRouter: NewsDetailsRouterProtocol {
    private(set) var dismissScreenCalled = false

    func dismissScreen() {
        dismissScreenCalled = true
    }
}
