//
//  NewsFeedViewModelTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.12.2025.
//

import Testing
@testable import AIChat

@MainActor
struct NewsFeedViewModelTests {

    // MARK: - Initial Load Tests

    @Test("Initial Data Load Success")
    func testInitialDataLoadSuccess() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        #expect(presenter.state == .idle)

        await presenter.loadInitialDataAndWait()

        #expect(presenter.articles.count > 0)
        if case .loaded = presenter.state {
            // Success
        } else {
            Issue.record("Expected state to be .loaded")
        }
    }

    @Test("Initial Data Load Failure")
    func testInitialDataLoadFailure() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: true, failWithError: NewsFeedError.networkError)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        await presenter.loadInitialDataAndWait()

        if case .error = presenter.state {
            // Success
        } else {
            Issue.record("Expected state to be .error")
        }
        #expect(presenter.errorMessage != nil)
    }

    // MARK: - Refresh Tests

    @Test("Refresh Data Resets Page and Articles")
    func testRefreshDataResetsPageAndArticles() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        // Load initial data
        await presenter.loadInitialDataAndWait()

        let initialCount = presenter.articles.count

        // Refresh
        await presenter.refreshDataAndWait()

        #expect(presenter.currentPage == 1)
        #expect(presenter.articles.count > 0)
    }

    // MARK: - Pagination Tests

    @Test("Load More Data Increments Page")
    func testLoadMoreDataIncrementsPage() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false, totalResults: 100)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        // Load initial data
        await presenter.loadInitialDataAndWait()

        let initialCount = presenter.articles.count
        #expect(presenter.currentPage == 1)

        // Load more
        await presenter.loadMoreDataAndWait()

        #expect(presenter.currentPage == 2)
        #expect(presenter.articles.count > initialCount)
    }

    @Test("Load More Data Stops When No More Pages")
    func testLoadMoreDataStopsWhenNoMorePages() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false, totalResults: 10)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        // Load initial data (pageSize=20, but only 10 total)
        await presenter.loadInitialDataAndWait()

        #expect(presenter.hasMorePages == false)

        let articleCountBeforeLoadMore = presenter.articles.count

        // Try to load more
        await presenter.loadMoreDataAndWait()

        // Should not have loaded more
        #expect(presenter.articles.count == articleCountBeforeLoadMore)
        #expect(presenter.currentPage == 1)
    }

    @Test("isLoadingMore Flag During Pagination")
    func testIsLoadingMoreFlagDuringPagination() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        // Load initial data
        await presenter.loadInitialDataAndWait()

        #expect(presenter.isLoadingMore == false)

        // Start loading more
        await presenter.loadMoreDataAndWait()
        #expect(presenter.isLoadingMore == false)
    }

    // MARK: - Connectivity Tests

    @Test("Data Source Indicator Shows Remote")
    func testDataSourceIndicatorShowsRemote() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false, dataSource: .remote, isConnected: true)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        await presenter.loadInitialDataAndWait()

        #expect(presenter.isDataFromRemote == true)
        #expect(presenter.isDataFromLocal == false)
    }

    @Test("Data Source Indicator Shows Local")
    func testDataSourceIndicatorShowsLocal() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false, dataSource: .local, isConnected: false)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        await presenter.loadInitialDataAndWait()

        #expect(presenter.isDataFromRemote == false)
        #expect(presenter.isDataFromLocal == true)
    }

    @Test("Auto-Refresh on Connectivity Restored")
    func testAutoRefreshOnConnectivityRestored() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false, dataSource: .local, isConnected: false)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        // Load initial data while offline
        await presenter.loadInitialDataAndWait()

        #expect(presenter.isDataFromLocal == true)

        // First handleConnectivityChange to set wasDisconnected = true
        await presenter.handleConnectivityChangeAndWait()

        // Restore connectivity and change data source to remote
        mockUseCase.setDataSource(.remote)
        mockUseCase.isConnected = true
        await presenter.handleConnectivityChangeAndWait()

        #expect(presenter.isDataFromRemote == true)
    }

    @Test("No Auto-Refresh When Already Remote")
    func testNoAutoRefreshWhenAlreadyRemote() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false, dataSource: .remote, isConnected: true)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        // Load initial data while online
        await presenter.loadInitialDataAndWait()

        let initialArticleCount = presenter.articles.count

        // Connectivity change (still connected)
        await presenter.handleConnectivityChangeAndWait()

        // Should not have refreshed since data was already from remote
        #expect(presenter.articles.count == initialArticleCount)
    }

    // MARK: - Error Mapping Tests

    @Test("Network Error Mapping")
    func testNetworkErrorMapping() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: true, failWithError: NewsFeedError.networkError)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        await presenter.loadInitialDataAndWait()

        #expect(presenter.errorMessage != nil)
        #expect(presenter.errorMessage?.contains("Network") == true || presenter.errorMessage?.contains("network") == true)
    }

    @Test("Invalid Response Error Mapping")
    func testInvalidResponseErrorMapping() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: true, failWithError: NewsFeedError.invalidResponse)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        await presenter.loadInitialDataAndWait()

        #expect(presenter.errorMessage != nil)
        #expect(presenter.errorMessage?.contains("Invalid") == true || presenter.errorMessage?.contains("invalid") == true)
    }

    // MARK: - State Management Tests

    @Test("State Transitions During Load")
    func testStateTransitionsDuringLoad() async throws {
        let mockUseCase = MockNewsFeedInteractor(shouldFail: false)

        let presenter = NewsFeedPresenter(
            newsFeedInteractor: mockUseCase,
            router: MockNewsFeedRouter()
        )

        // Initial state
        #expect(presenter.state == .idle)

        // Start loading
        await presenter.loadInitialDataAndWait()
        if case .loaded = presenter.state {
            // Success
        } else {
            Issue.record("Expected state to be .loaded")
        }
    }
}

// MARK: - Mock NewsFeedInteractor

@MainActor
final class MockNewsFeedRouter: NewsFeedRouterProtocol {
    private(set) var showNewsDetailsViewCalled = false
    private(set) var lastArticle: NewsArticle?

    func showNewsDetailsView(article: NewsArticle) {
        showNewsDetailsViewCalled = true
        lastArticle = article
    }
}

@MainActor
final class MockNewsFeedInteractor: NewsFeedInteractorProtocol {
    var shouldFail: Bool
    var failWithError: Error?
    var totalResults: Int
    var dataSource: NewsFeedResult.DataSource
    var isConnected: Bool

    private var mockArticles: [NewsArticle] = [
        .mock(title: "Article 1", description: "Description 1", category: "Tech"),
        .mock(title: "Article 2", description: "Description 2", category: "Science"),
        .mock(title: "Article 3", description: "Description 3", category: "Tech"),
        .mock(title: "Article 4", description: "Description 4", category: "General"),
        .mock(title: "Article 5", description: "Description 5", category: "General"),
        .mock(title: "Article 6", description: "Description 6", category: "General"),
        .mock(title: "Article 7", description: "Description 7", category: "General"),
        .mock(title: "Article 8", description: "Description 8", category: "General"),
        .mock(title: "Article 9", description: "Description 9", category: "General"),
        .mock(title: "Article 10", description: "Description 10", category: "General")
    ]

    init(shouldFail: Bool = false, failWithError: Error? = nil, totalResults: Int? = nil, dataSource: NewsFeedResult.DataSource = .remote, isConnected: Bool = true) {
        self.shouldFail = shouldFail
        self.failWithError = failWithError
        self.totalResults = totalResults ?? mockArticles.count
        self.dataSource = dataSource
        self.isConnected = isConnected
    }

    func setDataSource(_ source: NewsFeedResult.DataSource) {
        self.dataSource = source
    }

    func loadNews(category: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult {
        if shouldFail {
            throw failWithError ?? NewsFeedError.networkError
        }

        try await Task.sleep(nanoseconds: 50_000_000)

        return paginateArticles(mockArticles, page: page, pageSize: pageSize)
    }

    func loadTopHeadlines(country: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult {
        if shouldFail {
            throw failWithError ?? NewsFeedError.networkError
        }

        try await Task.sleep(nanoseconds: 50_000_000)

        return paginateArticles(mockArticles, page: page, pageSize: pageSize)
    }

    private func paginateArticles(_ articles: [NewsArticle], page: Int, pageSize: Int) -> NewsFeedResult {
        let startIndex = (page - 1) * pageSize

        // Generate enough mock articles to satisfy the request
        var allArticles = articles
        while allArticles.count < startIndex + pageSize && allArticles.count < totalResults {
            let nextIndex = allArticles.count + 1
            allArticles.append(.mock(
                title: "Article \(nextIndex)",
                description: "Description \(nextIndex)",
                category: "General"
            ))
        }

        let endIndex = min(startIndex + pageSize, allArticles.count, totalResults)

        let paginatedArticles: [NewsArticle]
        if startIndex < allArticles.count && startIndex < totalResults {
            paginatedArticles = Array(allArticles[startIndex..<endIndex])
        } else {
            paginatedArticles = []
        }

        return NewsFeedResult(
            articles: paginatedArticles,
            source: dataSource,
            totalResults: totalResults
        )
    }
}
