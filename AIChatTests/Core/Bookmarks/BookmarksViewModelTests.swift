//
//  BookmarksViewModelTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import Testing
@testable import AIChat

@MainActor
struct BookmarksViewModelTests {

    // MARK: - Initialization Tests

    @Test("ViewModel Initializes With Empty Bookmarks")
    func testViewModelInitializesWithEmptyBookmarks() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        #expect(viewModel.bookmarkedArticles.isEmpty)
    }

    // MARK: - Load Bookmarks Tests

    @Test("Load Bookmarks Retrieves Articles from UseCase")
    func testLoadBookmarksRetrievesArticlesFromUseCase() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        mockUseCase.articles = [article1, article2]

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        viewModel.loadBookmarks()

        #expect(viewModel.bookmarkedArticles.count == 2)
        #expect(viewModel.bookmarkedArticles[0].title == "Article 1")
        #expect(viewModel.bookmarkedArticles[1].title == "Article 2")
    }

    @Test("Load Bookmarks Tracks Start Event")
    func testLoadBookmarksTracksStartEvent() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        viewModel.loadBookmarks()

        let startEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "BookmarksView_LoadBookmarks_Start"
        }
        #expect(startEvents.count == 1)
    }

    @Test("Load Bookmarks Tracks Success Event With Count")
    func testLoadBookmarksTracksSuccessEventWithCount() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        let article3 = NewsArticle.mock(title: "Article 3")
        mockUseCase.articles = [article1, article2, article3]

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        viewModel.loadBookmarks()

        let successEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "BookmarksView_LoadBookmarks_Success"
        }
        #expect(successEvents.count == 1)
        #expect(successEvents.first?.parameters?["bookmarks_count"] as? Int == 3)
    }

    @Test("Load Bookmarks With Empty Result")
    func testLoadBookmarksWithEmptyResult() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()
        mockUseCase.articles = []

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        viewModel.loadBookmarks()

        #expect(viewModel.bookmarkedArticles.isEmpty)
        let successEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "BookmarksView_LoadBookmarks_Success"
        }
        #expect(successEvents.first?.parameters?["bookmarks_count"] as? Int == 0)
    }

    // MARK: - On Article Selected Tests

    @Test("On Article Selected Navigates to Details")
    func testOnArticleSelectedNavigatesToDetails() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        let article = NewsArticle.mock(title: "Test Article")
        viewModel.onArticleSelected(article: article)

        #expect(mockRouter.showNewsDetailsViewCalled)
        #expect(mockRouter.selectedArticle?.id == article.id)
    }

    @Test("On Article Selected Tracks Event")
    func testOnArticleSelectedTracksEvent() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        let article = NewsArticle.mock(title: "Tracked Article")
        viewModel.onArticleSelected(article: article)

        let articleEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "BookmarksView_Article_Pressed"
        }
        #expect(articleEvents.count == 1)
        #expect(articleEvents.first?.parameters?["article_id"] as? String == article.id)
        #expect(articleEvents.first?.parameters?["article_title"] as? String == article.title)
    }

    // MARK: - Remove Bookmark Tests

    @Test("Remove Bookmark Removes Article via UseCase")
    func testRemoveBookmarkRemovesArticleViaUseCase() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let article = NewsArticle.mock(title: "Remove Test")
        mockUseCase.articles = [article]

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        viewModel.loadBookmarks()
        #expect(viewModel.bookmarkedArticles.count == 1)

        mockUseCase.articles = []
        viewModel.removeBookmark(article: article)

        #expect(mockUseCase.removedArticleIds.contains(article.id))
        #expect(viewModel.bookmarkedArticles.isEmpty)
    }

    @Test("Remove Bookmark Tracks Event")
    func testRemoveBookmarkTracksEvent() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        let article = NewsArticle.mock(title: "Tracked Remove")
        viewModel.removeBookmark(article: article)

        let removeEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "BookmarksView_RemoveBookmark_Pressed"
        }
        #expect(removeEvents.count == 1)
        #expect(removeEvents.first?.parameters?["article_id"] as? String == article.id)
        #expect(removeEvents.first?.parameters?["article_title"] as? String == article.title)
    }

    @Test("Remove Bookmark Reloads Bookmarks")
    func testRemoveBookmarkReloadsBookmarks() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")
        mockUseCase.articles = [article1, article2]

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        viewModel.loadBookmarks()
        #expect(viewModel.bookmarkedArticles.count == 2)

        // Remove one article
        mockUseCase.articles = [article1]
        viewModel.removeBookmark(article: article2)

        #expect(viewModel.bookmarkedArticles.count == 1)
        #expect(viewModel.bookmarkedArticles[0].id == article1.id)
    }

    // MARK: - Multiple Operations Tests

    @Test("Load Bookmarks Multiple Times Updates Articles")
    func testLoadBookmarksMultipleTimesUpdatesArticles() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        // First load - empty
        mockUseCase.articles = []
        viewModel.loadBookmarks()
        #expect(viewModel.bookmarkedArticles.isEmpty)

        // Second load - one article
        let article = NewsArticle.mock(title: "New Article")
        mockUseCase.articles = [article]
        viewModel.loadBookmarks()
        #expect(viewModel.bookmarkedArticles.count == 1)

        // Third load - two articles
        let article2 = NewsArticle.mock(title: "Another Article")
        mockUseCase.articles = [article, article2]
        viewModel.loadBookmarks()
        #expect(viewModel.bookmarkedArticles.count == 2)
    }

    @Test("Multiple Article Selections Track Separate Events")
    func testMultipleArticleSelectionsTrackSeparateEvents() {
        let mockUseCase = MockBookmarksUseCase()
        let mockRouter = MockBookmarksRouter()

        let viewModel = BookmarksViewModel(
            bookmarksUseCase: mockUseCase,
            router: mockRouter
        )

        let article1 = NewsArticle.mock(title: "Article 1")
        let article2 = NewsArticle.mock(title: "Article 2")

        viewModel.onArticleSelected(article: article1)
        viewModel.onArticleSelected(article: article2)

        let articleEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "BookmarksView_Article_Pressed"
        }
        #expect(articleEvents.count == 2)
    }
}

// MARK: - Mock BookmarksUseCase

@MainActor
final class MockBookmarksUseCase: BookmarksUseCaseProtocol {

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
