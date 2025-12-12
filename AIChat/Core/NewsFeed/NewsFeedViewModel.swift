//
//  NewsFeedViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

@MainActor
@Observable
final class NewsFeedViewModel {
    
    // MARK: - State
    enum State: Equatable {
        case idle
        case loading
        case loaded([NewsArticle])
        case error(NewsFeedError)
        case loadingMore([NewsArticle])
    }

    enum NewsFeedError: LocalizedError, Equatable {
        case network
        case server(status: Int)
        case decoding
        case invalidResponse
        case unknown(message: String)
        
        var errorDescription: String? {
            switch self {
            case .network:
                return "Network connection error. Please check your internet connection."
            case .server(let status):
                return "Server error (Status: \(status)). Please try again later."
            case .decoding:
                return "Data format error. Please try again."
            case .invalidResponse:
                return "Invalid response from server. Please try again."
            case .unknown(let message):
                return message
            }
        }
    }
    
    // MARK: - Dependencies
    private let newsFeedUseCase: NewsFeedUseCaseProtocol
    private let networkMonitor: NetworkMonitorProtocol

    // MARK: - Published Properties
    private(set) var articles: [NewsArticle] = []
    private(set) var currentPage: Int = 1
    private(set) var hasMorePages: Bool = true
    private(set) var state: State = .idle
    private(set) var dataSource: NewsFeedResult.DataSource?
    private(set) var totalResults: Int?

    var isDataFromRemote: Bool {
        dataSource == .remote
    }

    var isDataFromLocal: Bool {
        dataSource == .local
    }

    var isConnected: Bool {
        networkMonitor.isConnected
    }

    // Helper to track current query context
    private var currentCountry: String? = "eg"
    private var currentCategory: String? = nil

    // Loading guard
    private var isLoading: Bool = false
    private let pageSize: Int = 20

    // Track previous connectivity state for auto-refresh
    private var wasDisconnected: Bool = false

    // MARK: - Initialization
    init(newsFeedUseCase: NewsFeedUseCaseProtocol, networkMonitor: NetworkMonitorProtocol) {
        self.newsFeedUseCase = newsFeedUseCase
        self.networkMonitor = networkMonitor
    }
    
    // MARK: - Public Methods
    func loadInitialData() {
        print("🔍 ViewModel: loadInitialData called. State: \(state)")
        Task { [weak self] in
            await self?.loadInitialDataAndWait()
        }
    }

    func handleConnectivityChange() {
        Task { [weak self] in
            await self?.handleConnectivityChangeAndWait()
        }
    }
    
    func refreshData() {
        print("🔍 ViewModel: refreshData called")
        Task { [weak self] in
            await self?.refreshDataAndWait()
        }
    }
    
    func loadMoreData() {
        print("🔍 ViewModel: loadMoreData called. Page: \(currentPage), HasMore: \(hasMorePages), IsLoading: \(isLoading)")
        Task { [weak self] in
            await self?.loadMoreDataAndWait()
        }
    }
    
    // MARK: - Async, test-friendly variants
    func loadInitialDataAndWait() async {
        guard case .idle = state else { return }
        await fetchData(page: 1)
    }
    
    func refreshDataAndWait() async {
        print("🔍 ViewModel: refreshDataAndWait called")
        currentPage = 1
        hasMorePages = true
        // Keep articles empty or keep old ones depending on preference, reference does this:
        articles = []
        state = .loading
        await fetchData(page: 1)
    }
    
    func loadMoreDataAndWait() async {
        guard hasMorePages && !isLoading else { return }
        await fetchData(page: currentPage + 1)
    }

    func handleConnectivityChangeAndWait() async {
        let isNowConnected = networkMonitor.isConnected

        if isNowConnected && wasDisconnected && isDataFromLocal {
            print("🔍 ViewModel: Connectivity restored! Auto-refreshing from remote...")
            await refreshDataAndWait()
        }

        wasDisconnected = !isNowConnected
    }
    
    func loadTopHeadlines(country: String? = "eg") {
        print("🔍 ViewModel: loadTopHeadlines called. Country: \(String(describing: country))")
        currentCountry = country
        currentCategory = nil
        resetAndFetch()
    }
    
    func loadNews(category: String?) {
        print("🔍 ViewModel: loadNews called. Category: \(String(describing: category))")
        currentCategory = category
        resetAndFetch()
    }
    
    // MARK: - Private Methods
    private func resetAndFetch() {
        currentPage = 1
        hasMorePages = true
        articles = []
        state = .loading
        Task { [weak self] in
            await self?.fetchData(page: 1)
        }
    }

    private func fetchData(page: Int) async {
        print("🔍 ViewModel: fetchData called for page \(page)")
        guard !isLoading else {
            print("🔍 ViewModel: Already loading. Skipping.")
            return
        }
        isLoading = true
        
        if page == 1 {
            state = .loading
        } else {
            state = .loadingMore(articles)
        }
        
        do {
            let result: NewsFeedResult
            if let category = currentCategory {
                print("🔍 ViewModel: Fetching News (Category: \(category))")
                result = try await newsFeedUseCase.loadNews(category: category, page: page, pageSize: pageSize)
            } else {
                print("🔍 ViewModel: Fetching Top Headlines (Country: \(currentCountry ?? "nil"))")
                result = try await newsFeedUseCase.loadTopHeadlines(country: currentCountry, page: page, pageSize: pageSize)
            }
            
            print("🔍 ViewModel: Success. Got \(result.articles.count) articles. Source: \(result.source). TotalResults: \(result.totalResults ?? -1)")

            if page == 1 {
                articles = result.articles
            } else {
                articles.append(contentsOf: result.articles)
            }

            currentPage = page
            totalResults = result.totalResults

            // Calculate hasMorePages based on totalResults if available
            if let total = result.totalResults {
                // Check if we have fetched all available articles
                hasMorePages = articles.count < total
                print("🔍 ViewModel: Pagination - Fetched \(articles.count) of \(total). HasMore: \(hasMorePages)")
            } else {
                // Fallback for local storage (no totalResults)
                // If we got fewer articles than requested, there are no more pages
                hasMorePages = result.articles.count >= pageSize
                print("🔍 ViewModel: Pagination - No totalResults. Got \(result.articles.count) articles (pageSize: \(pageSize)). HasMore: \(hasMorePages)")
            }

            dataSource = result.source
            state = .loaded(articles)
            print("🔍 ViewModel: State updated to .loaded. Articles count: \(articles.count)")
            
        } catch {
            print("🚨 ViewModel: Error: \(error)")
            if page == 1 {
                state = .error(mapError(error))
            } else {
                state = .loaded(articles)
            }
        }
        
        isLoading = false
    }
    
    private func mapError(_ error: Error) -> NewsFeedError {
        // Network connectivity
        if error is URLError {
            return .network
        }
        
        // JSON decoding / parsing
        if error is DecodingError {
            return .decoding
        }
        
        let nsError = error as NSError
        // Try to extract an HTTP status code if upstream attached it 
        // (RemoteNewsFeedService logs it but throws standard error, 
        // might need to cast to custom service error if it had associated value, 
        // but here we just check NSError userInfo or general mapping)
        if let status = nsError.userInfo["HTTPStatusCode"] as? Int {
            return .server(status: status)
        }
        
        if let newsError = error as? AIChat.NewsFeedError, newsError == .invalidResponse {
            return .invalidResponse
        }
        
        if let desc = (error as? LocalizedError)?.errorDescription, !desc.isEmpty {
            return .unknown(message: desc)
        }
        
        return .unknown(message: nsError.localizedDescription)
    }
}

extension NewsFeedViewModel {
    var errorMessage: String? {
        guard case .error(let error) = state else { return nil }
        return error.errorDescription
    }
    
    var isLoadingMore: Bool {
        guard case .loadingMore = state else { return false }
        return true
    }
}
