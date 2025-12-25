//
//  NewsFeedInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

/// Protocol defining the business logic interface for NewsFeed feature.
///
/// Architectural Note on Network Connectivity:
/// The `isConnected` property is exposed through this Interactor protocol to maintain proper
/// separation of concerns in Clean Architecture. The ViewModel needs network status to show
/// appropriate UI states (loading, error, offline), but should not directly access NetworkMonitor.
/// By exposing connectivity through the UseCase, we maintain the proper data flow:
/// View → ViewModel → UseCase → Manager/Service
@MainActor
protocol NewsFeedInteractorProtocol {
    /// Current network connectivity status.
    /// Exposed to enable ViewModel to show appropriate UI states without directly accessing NetworkMonitor.
    var isConnected: Bool { get }

    func loadNews(
        category: String?,
        language: String?,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult

    func loadTopHeadlines(
        country: String?,
        language: String?,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult
}

@MainActor
final class NewsFeedInteractor: NewsFeedInteractorProtocol {

    private let newsFeedManager: NewsFeedManagerProtocol
    private let networkMonitor: NetworkMonitorProtocol

    /// Delegates to NetworkMonitor to provide current connectivity status.
    /// NetworkMonitor is resolved from DependencyContainer, enabling test injection of MockNetworkMonitor.
    var isConnected: Bool {
        networkMonitor.isConnected
    }

    init(container: DependencyContainer) {
        guard let newsFeedManager = container.resolve(NewsFeedManager.self) else {
            preconditionFailure("Failed to resolve NewsFeedManager for NewsFeedInteractor")
        }
        // Resolve NetworkMonitorProtocol to enable mock injection during testing
        guard let networkMonitor = container.resolve(NetworkMonitorProtocol.self) else {
            preconditionFailure("Failed to resolve NetworkMonitorProtocol for NewsFeedInteractor")
        }
        self.newsFeedManager = newsFeedManager
        self.networkMonitor = networkMonitor
    }

    func loadNews(
        category: String? = nil,
        language: String? = nil,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult {
        try await newsFeedManager
            .fetchNews(
                category: category,
                language: language,
                page: page,
                pageSize: pageSize
            )
    }

    func loadTopHeadlines(
        country: String? = nil,
        language: String? = nil,
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResult {
        try await newsFeedManager
            .fetchTopHeadlines(
                country: country,
                language: language,
                page: page,
                pageSize: pageSize
            )
    }
}
