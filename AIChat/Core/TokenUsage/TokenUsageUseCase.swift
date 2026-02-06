//
//  TokenUsageUseCase.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import Foundation
import SwiftfulUtilities

@MainActor
protocol TokenUsageUseCaseProtocol {
    func fetchUsage(range: TokenUsageRange) async throws -> [TokenUsageEntry]
    func apiKey(for provider: TokenUsageProvider) -> String?
    func saveAPIKey(_ apiKey: String, for provider: TokenUsageProvider) throws
    func clearAPIKey(for provider: TokenUsageProvider) throws
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class TokenUsageUseCase {

    private let logManager: LogManager?
    private let credentialsStore: TokenUsageCredentialsStoreProtocol
    private let apiClient: TokenUsageAPIClientProtocol

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
        self.credentialsStore = TokenUsageCredentialsStore()
        self.apiClient = TokenUsageAPIClient(logManager: logManager)
    }
}

extension TokenUsageUseCase: TokenUsageUseCaseProtocol {

    func fetchUsage(range: TokenUsageRange) async throws -> [TokenUsageEntry] {
        let now = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -range.rawValue, to: now)
        let period = DateInterval(start: startDate ?? now, end: now)
        var entries: [TokenUsageEntry] = []

        for provider in TokenUsageProvider.allCases {
            guard let apiKey = credentialsStore.apiKey(for: provider), !apiKey.isEmpty else {
                entries.append(TokenUsageEntry(
                    provider: provider,
                    tokensUsed: 0,
                    tokenLimit: nil,
                    billingPeriod: period,
                    lastUpdated: now,
                    status: .needsConfiguration,
                    bucketCount: nil,
                    lastBucket: nil
                ))
                continue
            }

            do {
                let summary = try await fetchUsageSummary(
                    for: provider,
                    apiKey: apiKey,
                    period: period
                )

                entries.append(TokenUsageEntry(
                    provider: provider,
                    tokensUsed: summary.tokensUsed,
                    tokenLimit: nil,
                    billingPeriod: period,
                    lastUpdated: now,
                    status: .ready,
                    bucketCount: summary.bucketCount,
                    lastBucket: summary.lastBucket
                ))
            } catch {
                entries.append(TokenUsageEntry(
                    provider: provider,
                    tokensUsed: 0,
                    tokenLimit: nil,
                    billingPeriod: period,
                    lastUpdated: now,
                    status: .unavailable(message: unavailableMessage(for: provider, error: error)),
                    bucketCount: nil,
                    lastBucket: nil
                ))
            }
        }

        return entries
    }

    func apiKey(for provider: TokenUsageProvider) -> String? {
        credentialsStore.apiKey(for: provider)
    }

    func saveAPIKey(_ apiKey: String, for provider: TokenUsageProvider) throws {
        try credentialsStore.saveAPIKey(apiKey, for: provider)
    }

    func clearAPIKey(for provider: TokenUsageProvider) throws {
        try credentialsStore.clearAPIKey(for: provider)
    }

    func trackEvent(event: any LoggableEvent) {
        logManager?.trackEvent(event: event)
    }
}

private extension TokenUsageUseCase {
    func fetchUsageSummary(
        for provider: TokenUsageProvider,
        apiKey: String,
        period: DateInterval
    ) async throws -> TokenUsageSummary {
        switch provider {
        case .claude:
            return try await apiClient.fetchAnthropicUsageSummary(apiKey: apiKey, period: period)
        case .codex:
            return try await apiClient.fetchOpenAIUsageSummary(apiKey: apiKey, period: period)
        }
    }

    func unavailableMessage(for provider: TokenUsageProvider, error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .unauthorized, .forbidden:
                return "\(provider.displayName) usage reports require an admin API key."
            default:
                return networkError.errorDescription ?? error.localizedDescription
            }
        }
        return error.localizedDescription
    }
}
