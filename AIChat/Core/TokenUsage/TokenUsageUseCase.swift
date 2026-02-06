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
    func fetchUsage() async throws -> [TokenUsageEntry]
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class TokenUsageUseCase {

    private let logManager: LogManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
    }
}

extension TokenUsageUseCase: TokenUsageUseCaseProtocol {

    func fetchUsage() async throws -> [TokenUsageEntry] {
        let now = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -30, to: now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: now)
        let period = DateInterval(start: startDate ?? now, end: endDate ?? now)

        return [
            TokenUsageEntry(
                providerName: "Claude",
                productName: "Claude API",
                tokensUsed: 0,
                tokenLimit: nil,
                billingPeriod: period,
                lastUpdated: now,
                status: .needsConfiguration
            ),
            TokenUsageEntry(
                providerName: "Codex",
                productName: "OpenAI Codex",
                tokensUsed: 0,
                tokenLimit: nil,
                billingPeriod: period,
                lastUpdated: now,
                status: .needsConfiguration
            )
        ]
    }

    func trackEvent(event: any LoggableEvent) {
        logManager?.trackEvent(event: event)
    }
}
