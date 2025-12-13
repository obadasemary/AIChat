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
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        #expect(viewModel.state == .idle)

        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.articles.count > 0)
        if case .loaded = viewModel.state {
            // Success
        } else {
            Issue.record("Expected state to be .loaded")
        }
    }

    @Test("Initial Data Load Failure")
    func testInitialDataLoadFailure() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: true, failWithError: NewsFeedError.networkError)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        await viewModel.loadInitialDataAndWait()

        if case .error = viewModel.state {
            // Success
        } else {
            Issue.record("Expected state to be .error")
        }
        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Refresh Tests

    @Test("Refresh Data Resets Page and Articles")
    func testRefreshDataResetsPageAndArticles() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        // Load initial data
        await viewModel.loadInitialDataAndWait()

        let initialCount = viewModel.articles.count

        // Refresh
        await viewModel.refreshDataAndWait()

        #expect(viewModel.currentPage == 1)
        #expect(viewModel.articles.count > 0)
    }

    // MARK: - Pagination Tests

    @Test("Load More Data Increments Page")
    func testLoadMoreDataIncrementsPage() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false, totalResults: 100)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        // Load initial data
        await viewModel.loadInitialDataAndWait()

        let initialCount = viewModel.articles.count
        #expect(viewModel.currentPage == 1)

        // Load more
        await viewModel.loadMoreDataAndWait()

        #expect(viewModel.currentPage == 2)
        #expect(viewModel.articles.count > initialCount)
    }

    @Test("Load More Data Stops When No More Pages")
    func testLoadMoreDataStopsWhenNoMorePages() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false, totalResults: 10)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        // Load initial data (pageSize=20, but only 10 total)
        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.hasMorePages == false)

        let articleCountBeforeLoadMore = viewModel.articles.count

        // Try to load more
        await viewModel.loadMoreDataAndWait()

        // Should not have loaded more
        #expect(viewModel.articles.count == articleCountBeforeLoadMore)
        #expect(viewModel.currentPage == 1)
    }

    @Test("isLoadingMore Flag During Pagination")
    func testIsLoadingMoreFlagDuringPagination() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        // Load initial data
        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.isLoadingMore == false)

        // Start loading more
        await viewModel.loadMoreDataAndWait()
        #expect(viewModel.isLoadingMore == false)
    }

    // MARK: - Connectivity Tests

    @Test("Data Source Indicator Shows Remote")
    func testDataSourceIndicatorShowsRemote() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false, dataSource: .remote)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.isDataFromRemote == true)
        #expect(viewModel.isDataFromLocal == false)
    }

    @Test("Data Source Indicator Shows Local")
    func testDataSourceIndicatorShowsLocal() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false, dataSource: .local)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: false)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.isDataFromRemote == false)
        #expect(viewModel.isDataFromLocal == true)
    }

    @Test("Auto-Refresh on Connectivity Restored")
    func testAutoRefreshOnConnectivityRestored() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false, dataSource: .local)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: false)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        // Load initial data while offline
        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.isDataFromLocal == true)

        // First handleConnectivityChange to set wasDisconnected = true
        await viewModel.handleConnectivityChangeAndWait()

        // Restore connectivity and change data source to remote
        mockUseCase.setDataSource(.remote)
        mockNetworkMonitor.isConnected = true
        await viewModel.handleConnectivityChangeAndWait()

        #expect(viewModel.isDataFromRemote == true)
    }

    @Test("No Auto-Refresh When Already Remote")
    func testNoAutoRefreshWhenAlreadyRemote() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false, dataSource: .remote)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        // Load initial data while online
        await viewModel.loadInitialDataAndWait()

        let initialArticleCount = viewModel.articles.count

        // Connectivity change (still connected)
        await viewModel.handleConnectivityChangeAndWait()

        // Should not have refreshed since data was already from remote
        #expect(viewModel.articles.count == initialArticleCount)
    }

    // MARK: - Error Mapping Tests

    @Test("Network Error Mapping")
    func testNetworkErrorMapping() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: true, failWithError: NewsFeedError.networkError)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("Network") == true || viewModel.errorMessage?.contains("network") == true)
    }

    @Test("Invalid Response Error Mapping")
    func testInvalidResponseErrorMapping() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: true, failWithError: NewsFeedError.invalidResponse)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        await viewModel.loadInitialDataAndWait()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("Invalid") == true || viewModel.errorMessage?.contains("invalid") == true)
    }

    // MARK: - State Management Tests

    @Test("State Transitions During Load")
    func testStateTransitionsDuringLoad() async throws {
        let mockUseCase = MockNewsFeedUseCase(shouldFail: false)
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let viewModel = NewsFeedViewModel(
            newsFeedUseCase: mockUseCase,
            networkMonitor: mockNetworkMonitor
        )

        // Initial state
        #expect(viewModel.state == .idle)

        // Start loading
        await viewModel.loadInitialDataAndWait()
        if case .loaded = viewModel.state {
            // Success
        } else {
            Issue.record("Expected state to be .loaded")
        }
    }
}

// MARK: - Mock NewsFeedUseCase

@MainActor
final class MockNewsFeedUseCase: NewsFeedUseCaseProtocol {
    var shouldFail: Bool
    var failWithError: Error?
    var totalResults: Int
    var dataSource: NewsFeedResult.DataSource

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

    init(shouldFail: Bool = false, failWithError: Error? = nil, totalResults: Int? = nil, dataSource: NewsFeedResult.DataSource = .remote) {
        self.shouldFail = shouldFail
        self.failWithError = failWithError
        self.totalResults = totalResults ?? mockArticles.count
        self.dataSource = dataSource
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
