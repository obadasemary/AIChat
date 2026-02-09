//
//  NewsFeedManagerTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.12.2025.
//

import Testing
@testable import AIChat

@MainActor
struct NewsFeedManagerTests {

    // MARK: - Fetch News Tests

    @Test("Fetch News from Remote when Connected")
    func testFetchNewsFromRemoteWhenConnected() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        let result = try await manager.fetchNews(category: nil, language: nil, page: 1, pageSize: 20)

        #expect(result.source == .remote)
        #expect(!result.articles.isEmpty)
        #expect(result.totalResults != nil)
    }

    @Test("Fetch News from Local when Offline")
    func testFetchNewsFromLocalWhenOffline() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        // Pre-populate local storage
        try mockLocalService.saveNews([
            .mock(title: "Cached Article 1", description: "Cached content 1", category: "Tech"),
            .mock(title: "Cached Article 2", description: "Cached content 2", category: "Science")
        ])

        let mockNetworkMonitor = MockNetworkMonitor(isConnected: false)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        let result = try await manager.fetchNews(category: nil, language: nil, page: 1, pageSize: 20)

        #expect(result.source == .local)
        #expect(result.articles.count == 2)
        #expect(result.totalResults == nil)
    }

    @Test("Fallback to Local when Remote Fails")
    func testFallbackToLocalWhenRemoteFails() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        mockRemoteService.shouldFail = true

        let mockLocalService = MockLocalNewsFeedService()
        try mockLocalService.saveNews([
            .mock(title: "Cached Article", description: "Cached content", category: "Tech")
        ])

        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        let result = try await manager.fetchNews(category: nil, language: nil, page: 1, pageSize: 20)

        #expect(result.source == .local)
        #expect(result.articles.count == 1)
    }

    @Test("Save Articles to Local Storage on Successful Remote Fetch")
    func testSaveArticlesToLocalStorageOnSuccess() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        _ = try await manager.fetchNews(category: nil, language: nil, page: 1, pageSize: 20)

        // Verify articles were saved to local storage
        let cachedArticles = try mockLocalService.fetchCachedNews()
        #expect(!cachedArticles.isEmpty)
    }

    @Test("Filter News by Category")
    func testFilterNewsByCategory() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        let result = try await manager.fetchNews(category: "Technology", language: nil, page: 1, pageSize: 20)

        #expect(result.source == .remote)
        #expect(result.articles.allSatisfy { $0.category == "Technology" })
    }

    // MARK: - Fetch Top Headlines Tests

    @Test("Fetch Top Headlines from Remote when Connected")
    func testFetchTopHeadlinesFromRemoteWhenConnected() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        let result = try await manager.fetchTopHeadlines(country: "us", language: nil, page: 1, pageSize: 20)

        #expect(result.source == .remote)
        #expect(!result.articles.isEmpty)
        #expect(result.totalResults != nil)
    }

    @Test("Fetch Top Headlines from Local when Offline")
    func testFetchTopHeadlinesFromLocalWhenOffline() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        try mockLocalService.saveNews([
            .mock(title: "Headline 1", description: "Description 1", category: "General")
        ])

        let mockNetworkMonitor = MockNetworkMonitor(isConnected: false)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        let result = try await manager.fetchTopHeadlines(country: "us", language: nil, page: 1, pageSize: 20)

        #expect(result.source == .local)
        #expect(result.articles.count == 1)
    }

    @Test("Pagination Returns Correct Page Size")
    func testPaginationReturnsCorrectPageSize() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        let result = try await manager.fetchNews(category: nil, language: nil, page: 1, pageSize: 5)

        #expect(result.articles.count <= 5)
    }

    @Test("Pagination Returns Empty on Beyond Last Page")
    func testPaginationReturnsEmptyBeyondLastPage() async throws {
        let mockRemoteService = MockRemoteNewsFeedService()
        let mockLocalService = MockLocalNewsFeedService()
        let mockNetworkMonitor = MockNetworkMonitor(isConnected: true)

        let manager = NewsFeedManager(
            remoteService: mockRemoteService,
            localStorage: mockLocalService,
            networkMonitor: mockNetworkMonitor,
            logManager: nil
        )

        // Mock service has 13 articles, fetch page 10 with pageSize 20
        let result = try await manager.fetchNews(category: nil, language: nil, page: 10, pageSize: 20)

        #expect(result.articles.isEmpty)
    }
}
