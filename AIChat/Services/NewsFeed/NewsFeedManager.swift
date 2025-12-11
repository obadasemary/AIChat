//
//  NewsFeedManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

@MainActor
@Observable
final class NewsFeedManager {

    private let remoteService: RemoteNewsFeedServiceProtocol
    private let localStorage: LocalNewsFeedServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    private let logManager: LogManagerProtocol?

    init(
        remoteService: RemoteNewsFeedServiceProtocol,
        localStorage: LocalNewsFeedServiceProtocol,
        networkMonitor: NetworkMonitorProtocol,
        logManager: LogManagerProtocol? = nil
    ) {
        self.remoteService = remoteService
        self.localStorage = localStorage
        self.networkMonitor = networkMonitor
        self.logManager = logManager
    }
}

extension NewsFeedManager: NewsFeedManagerProtocol {

    func fetchNews(category: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult {
        logManager?.trackEvent(event: Event.fetchNewsStart(category: category))

        if networkMonitor.isConnected {
            do {
                let response = try await remoteService.fetchNews(category: category, page: page, pageSize: pageSize)
                logManager?.trackEvent(event: Event.fetchNewsRemoteSuccess(count: response.articles.count))

                try localStorage.saveNews(response.articles)
                logManager?.trackEvent(event: Event.saveLocalSuccess(count: response.articles.count))

                return NewsFeedResult(
                    articles: response.articles,
                    source: .remote,
                    totalResults: response.totalResults
                )
            } catch {
                logManager?.trackEvent(event: Event.fetchNewsRemoteFail(error: error))

                return try fetchFromLocalStorage()
            }
        } else {
            logManager?.trackEvent(event: Event.noConnectivity)
            return try fetchFromLocalStorage()
        }
    }

    func fetchTopHeadlines(country: String?, page: Int, pageSize: Int) async throws -> NewsFeedResult {
        logManager?.trackEvent(event: Event.fetchTopHeadlinesStart(country: country))

        if networkMonitor.isConnected {
            do {
                let response = try await remoteService.fetchTopHeadlines(country: country, page: page, pageSize: pageSize)
                logManager?.trackEvent(event: Event.fetchTopHeadlinesRemoteSuccess(count: response.articles.count))

                try localStorage.saveNews(response.articles)
                logManager?.trackEvent(event: Event.saveLocalSuccess(count: response.articles.count))

                return NewsFeedResult(
                    articles: response.articles,
                    source: .remote,
                    totalResults: response.totalResults
                )
            } catch {
                logManager?.trackEvent(event: Event.fetchTopHeadlinesRemoteFail(error: error))

                return try fetchFromLocalStorage()
            }
        } else {
            logManager?.trackEvent(event: Event.noConnectivity)
            return try fetchFromLocalStorage()
        }
    }
}

// MARK: - Private Helpers
private extension NewsFeedManager {

    func fetchFromLocalStorage() throws -> NewsFeedResult {
        logManager?.trackEvent(event: Event.fetchLocalStart)

        let articles = try localStorage.fetchCachedNews()
        logManager?.trackEvent(event: Event.fetchLocalSuccess(count: articles.count))

        return NewsFeedResult(articles: articles, source: .local, totalResults: nil)
    }
}

// MARK: - Event
private extension NewsFeedManager {

    enum Event: LoggableEvent {
        case fetchNewsStart(category: String?)
        case fetchNewsRemoteSuccess(count: Int)
        case fetchNewsRemoteFail(error: Error)
        case fetchTopHeadlinesStart(country: String?)
        case fetchTopHeadlinesRemoteSuccess(count: Int)
        case fetchTopHeadlinesRemoteFail(error: Error)
        case noConnectivity
        case fetchLocalStart
        case fetchLocalSuccess(count: Int)
        case fetchLocalFail(error: Error)
        case saveLocalSuccess(count: Int)
        case saveLocalFail(error: Error)

        var eventName: String {
            switch self {
            case .fetchNewsStart: "NewsFeedMan_FetchNews_Start"
            case .fetchNewsRemoteSuccess: "NewsFeedMan_FetchNews_Remote_Success"
            case .fetchNewsRemoteFail: "NewsFeedMan_FetchNews_Remote_Fail"
            case .fetchTopHeadlinesStart: "NewsFeedMan_FetchTopHeadlines_Start"
            case .fetchTopHeadlinesRemoteSuccess: "NewsFeedMan_FetchTopHeadlines_Remote_Success"
            case .fetchTopHeadlinesRemoteFail: "NewsFeedMan_FetchTopHeadlines_Remote_Fail"
            case .noConnectivity: "NewsFeedMan_NoConnectivity"
            case .fetchLocalStart: "NewsFeedMan_FetchLocal_Start"
            case .fetchLocalSuccess: "NewsFeedMan_FetchLocal_Success"
            case .fetchLocalFail: "NewsFeedMan_FetchLocal_Fail"
            case .saveLocalSuccess: "NewsFeedMan_SaveLocal_Success"
            case .saveLocalFail: "NewsFeedMan_SaveLocal_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .fetchNewsStart(let category):
                return category != nil ? ["category": category ?? ""] : nil
            case .fetchNewsRemoteSuccess(let count),
                 .fetchTopHeadlinesRemoteSuccess(let count),
                 .fetchLocalSuccess(let count),
                 .saveLocalSuccess(let count):
                return ["count": count]
            case .fetchTopHeadlinesStart(let country):
                return country != nil ? ["country": country ?? ""] : nil
            case .fetchNewsRemoteFail(let error),
                 .fetchTopHeadlinesRemoteFail(let error),
                 .fetchLocalFail(let error),
                 .saveLocalFail(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .fetchNewsRemoteFail, .fetchTopHeadlinesRemoteFail, .fetchLocalFail, .saveLocalFail:
                return .severe
            case .noConnectivity:
                return .info
            default:
                return .analytic
            }
        }
    }
}
