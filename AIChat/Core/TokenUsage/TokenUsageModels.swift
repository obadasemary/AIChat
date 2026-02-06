//
//  TokenUsageModels.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import Foundation

struct TokenUsageEntry: Identifiable, Hashable {
    let id: UUID
    let providerName: String
    let productName: String
    let tokensUsed: Int
    let tokenLimit: Int?
    let billingPeriod: DateInterval?
    let lastUpdated: Date
    let status: TokenUsageStatus

    init(
        id: UUID = UUID(),
        providerName: String,
        productName: String,
        tokensUsed: Int,
        tokenLimit: Int?,
        billingPeriod: DateInterval?,
        lastUpdated: Date,
        status: TokenUsageStatus
    ) {
        self.id = id
        self.providerName = providerName
        self.productName = productName
        self.tokensUsed = tokensUsed
        self.tokenLimit = tokenLimit
        self.billingPeriod = billingPeriod
        self.lastUpdated = lastUpdated
        self.status = status
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
