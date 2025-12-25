//
//  BookmarksPresenterTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import Testing
@testable import AIChat

@MainActor
struct BookmarksPresenterTests {

    // MARK: - Initialization Tests

    @Test("ViewModel Initializes With Empty Bookmarks")
    func testViewModelInitializesWithEmptyBookmarks() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        #expect(presenter.bookmarkedArticles.isEmpty)
    }

    // MARK: - Load Bookmarks Tests

    @Test("Load Bookmarks Retrieves Articles from UseCase")
    func testLoadBookmarksRetrievesArticlesFromInteractor() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        mockInteractor.articles = [article1, article2]

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        presenter.loadBookmarks()

        #expect(presenter.bookmarkedArticles.count == 2)
        #expect(presenter.bookmarkedArticles[0].title == "Article 1")
        #expect(presenter.bookmarkedArticles[1].title == "Article 2")
    }

    @Test("Load Bookmarks Tracks Start Event")
    func testLoadBookmarksTracksStartEvent() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        presenter.loadBookmarks()

        let startEvents = mockInteractor.trackedEvents.filter {
            $0.eventName == "BookmarksView_LoadBookmarks_Start"
        }
        #expect(startEvents.count == 1)
    }

    @Test("Load Bookmarks Tracks Success Event With Count")
    func testLoadBookmarksTracksSuccessEventWithCount() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        let article3 = NewsArticle.mock(title: "Article 3")
        mockInteractor.articles = [article1, article2, article3]

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        presenter.loadBookmarks()

        let successEvents = mockInteractor.trackedEvents.filter {
            $0.eventName == "BookmarksView_LoadBookmarks_Success"
        }
        #expect(successEvents.count == 1)
        #expect(successEvents.first?.parameters?["bookmarks_count"] as? Int == 3)
    }

    @Test("Load Bookmarks With Empty Result")
    func testLoadBookmarksWithEmptyResult() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()
        mockInteractor.articles = []

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        presenter.loadBookmarks()

        #expect(presenter.bookmarkedArticles.isEmpty)
        let successEvents = mockInteractor.trackedEvents.filter {
            $0.eventName == "BookmarksView_LoadBookmarks_Success"
        }
        #expect(successEvents.first?.parameters?["bookmarks_count"] as? Int == 0)
    }

    // MARK: - On Article Selected Tests

    @Test("On Article Selected Navigates to Details")
    func testOnArticleSelectedNavigatesToDetails() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        let article = NewsArticle.mock(title: "Test Article")
        presenter.onArticleSelected(article: article)

        #expect(mockRouter.showNewsDetailsViewCalled)
        #expect(mockRouter.selectedArticle?.id == article.id)
    }

    @Test("On Article Selected Tracks Event")
    func testOnArticleSelectedTracksEvent() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        let article = NewsArticle.mock(title: "Tracked Article")
        presenter.onArticleSelected(article: article)

        let articleEvents = mockInteractor.trackedEvents.filter {
            $0.eventName == "BookmarksView_Article_Pressed"
        }
        #expect(articleEvents.count == 1)
        #expect(articleEvents.first?.parameters?["article_id"] as? String == article.id)
        #expect(articleEvents.first?.parameters?["article_title"] as? String == article.title)
    }

    // MARK: - Remove Bookmark Tests

    @Test("Remove Bookmark Removes Article via UseCase")
    func testRemoveBookmarkRemovesArticleViaInteractor() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let article = NewsArticle.mock(title: "Remove Test")
        mockInteractor.articles = [article]

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        presenter.loadBookmarks()
        #expect(presenter.bookmarkedArticles.count == 1)

        mockInteractor.articles = []
        presenter.removeBookmark(article: article)

        #expect(mockInteractor.removedArticleIds.contains(article.id))
        #expect(presenter.bookmarkedArticles.isEmpty)
    }

    @Test("Remove Bookmark Tracks Event")
    func testRemoveBookmarkTracksEvent() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        let article = NewsArticle.mock(title: "Tracked Remove")
        presenter.removeBookmark(article: article)

        let removeEvents = mockInteractor.trackedEvents.filter {
            $0.eventName == "BookmarksView_RemoveBookmark_Pressed"
        }
        #expect(removeEvents.count == 1)
        #expect(removeEvents.first?.parameters?["article_id"] as? String == article.id)
        #expect(removeEvents.first?.parameters?["article_title"] as? String == article.title)
    }

    @Test("Remove Bookmark Reloads Bookmarks")
    func testRemoveBookmarkReloadsBookmarks() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        mockInteractor.articles = [article1, article2]

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        presenter.loadBookmarks()
        #expect(presenter.bookmarkedArticles.count == 2)

        // Remove one article
        mockInteractor.articles = [article1]
        presenter.removeBookmark(article: article2)

        #expect(presenter.bookmarkedArticles.count == 1)
        #expect(presenter.bookmarkedArticles[0].id == article1.id)
    }

    // MARK: - Multiple Operations Tests

    @Test("Load Bookmarks Multiple Times Updates Articles")
    func testLoadBookmarksMultipleTimesUpdatesArticles() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        // First load - empty
        mockInteractor.articles = []
        presenter.loadBookmarks()
        #expect(presenter.bookmarkedArticles.isEmpty)

        // Second load - one article
        let article = NewsArticle.mock(title: "New Article")
        mockInteractor.articles = [article]
        presenter.loadBookmarks()
        #expect(presenter.bookmarkedArticles.count == 1)

        // Third load - two articles
        let article2 = NewsArticle.mock(title: "Another Article")
        mockInteractor.articles = [article, article2]
        presenter.loadBookmarks()
        #expect(presenter.bookmarkedArticles.count == 2)
    }

    @Test("Multiple Article Selections Track Separate Events")
    func testMultipleArticleSelectionsTrackSeparateEvents() {
        let mockInteractor = MockBookmarksInteractor()
        let mockRouter = MockBookmarksRouter()

        let presenter = BookmarksPresenter(
            bookmarksInteractor: mockInteractor,
            router: mockRouter
        )

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")

        presenter.onArticleSelected(article: article1)
        presenter.onArticleSelected(article: article2)

        let articleEvents = mockInteractor.trackedEvents.filter {
            $0.eventName == "BookmarksView_Article_Pressed"
        }
        #expect(articleEvents.count == 2)
    }
}

// MARK: - Mock BookmarksInteractor

@MainActor
final class MockBookmarksInteractor: BookmarksInteractorProtocol {

    var articles: [NewsArticle] = []
    var removedArticleIds: [String] = []
    var trackedEvents: [any LoggableEvent] = []

    func getBookmarkedArticles() -> [NewsArticle] {
        return articles
    }

    func removeBookmark(articleId: String) {
        removedArticleIds.append(articleId)
        articles.removeAll { $0.id == articleId }
    }

    func trackEvent(event: any LoggableEvent) {
        trackedEvents.append(event)
    }
}

// MARK: - Mock BookmarksRouter

@MainActor
final class MockBookmarksRouter: BookmarksRouterProtocol {

    private(set) var showNewsDetailsViewCalled = false
    private(set) var selectedArticle: NewsArticle?

    func showNewsDetailsView(article: NewsArticle) {
        showNewsDetailsViewCalled = true
        selectedArticle = article
    }
}
