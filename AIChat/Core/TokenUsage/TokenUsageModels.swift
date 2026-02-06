//
//  TokenUsageModels.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import Foundation

enum TokenUsageProvider: String, CaseIterable, Identifiable, Hashable {
    case claude
    case codex

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claude:
            return "Claude"
        case .codex:
            return "Codex"
        }
    }

    var productName: String {
        switch self {
        case .claude:
            return "Claude API"
        case .codex:
            return "OpenAI Codex"
        }
    }
}

enum TokenUsageRange: Int, CaseIterable, Identifiable {
    case last7 = 7
    case last30 = 30
    case last90 = 90

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .last7:
            return "7D"
        case .last30:
            return "30D"
        case .last90:
            return "90D"
        }
    }
}

struct TokenUsageSummary: Hashable {
    let tokensUsed: Int
    let bucketCount: Int
    let lastBucket: DateInterval?
}

struct TokenUsageEntry: Identifiable, Hashable {
    let id: UUID
    let provider: TokenUsageProvider
    let tokensUsed: Int
    let tokenLimit: Int?
    let billingPeriod: DateInterval?
    let lastUpdated: Date
    let status: TokenUsageStatus
    let bucketCount: Int?
    let lastBucket: DateInterval?

    init(
        id: UUID = UUID(),
        provider: TokenUsageProvider,
        tokensUsed: Int,
        tokenLimit: Int?,
        billingPeriod: DateInterval?,
        lastUpdated: Date,
        status: TokenUsageStatus,
        bucketCount: Int? = nil,
        lastBucket: DateInterval? = nil
    ) {
        self.id = id
        self.provider = provider
        self.tokensUsed = tokensUsed
        self.tokenLimit = tokenLimit
        self.billingPeriod = billingPeriod
        self.lastUpdated = lastUpdated
        self.status = status
        self.bucketCount = bucketCount
        self.lastBucket = lastBucket
    }

    var providerName: String {
        provider.displayName
    }

    var productName: String {
        provider.productName
    }

    var usageFraction: Double? {
        guard let tokenLimit, tokenLimit > 0 else {
            return nil
        }
        return Double(tokensUsed) / Double(tokenLimit)
    }
}

enum TokenUsageStatus: Hashable {
    case ready
    case needsConfiguration
    case unavailable(message: String)

    var title: String {
        switch self {
        case .ready:
            return "Live"
        case .needsConfiguration:
            return "Not Configured"
        case .unavailable:
            return "Unavailable"
        }
    }

    var subtitle: String {
        switch self {
        case .ready:
            return "Usage is fetched from your provider dashboards."
        case .needsConfiguration:
            return "Add provider API credentials to enable live usage."
        case .unavailable(let message):
            return message
        }
    }
}
