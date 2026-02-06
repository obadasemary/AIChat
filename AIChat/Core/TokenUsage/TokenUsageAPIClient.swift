//
//  TokenUsageAPIClient.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import Foundation

@MainActor
protocol TokenUsageAPIClientProtocol {
    func fetchOpenAIUsageSummary(apiKey: String, period: DateInterval) async throws -> TokenUsageSummary
    func fetchAnthropicUsageSummary(apiKey: String, period: DateInterval) async throws -> TokenUsageSummary
}

@MainActor
struct TokenUsageAPIClient: TokenUsageAPIClientProtocol {
    private let openAIManager: NetworkManagerProtocol
    private let anthropicManager: NetworkManagerProtocol

    init(logManager: LogManagerProtocol? = nil) {
        let service = URLSessionNetworkService(baseURL: nil)
        self.openAIManager = NetworkManager(service: service, logManager: logManager)
        self.anthropicManager = NetworkManager(service: service, logManager: logManager)
    }

    func fetchOpenAIUsageSummary(apiKey: String, period: DateInterval) async throws -> TokenUsageSummary {
        var totalTokens = 0
        var bucketCount = 0
        var lastBucket: DateInterval?
        var nextPage: String?
        repeat {
            var parameters = openAIQueryParameters(period: period)
            if let nextPage {
                parameters["page"] = nextPage
            }

            let request = NetworkRequest.get(
                "https://api.openai.com/v1/organization/usage/completions",
                queryParameters: parameters,
                headers: [
                    "Authorization": "Bearer \(apiKey)",
                    "Content-Type": "application/json"
                ]
            )

            let response: OpenAIUsageResponse = try await openAIManager.execute(
                request,
                responseType: OpenAIUsageResponse.self
            )

            totalTokens += response.totalTokens
            bucketCount += response.data.count
            lastBucket = lastBucketInterval(current: lastBucket, next: response.lastBucketInterval)
            nextPage = response.nextPage
        } while nextPage != nil

        return TokenUsageSummary(
            tokensUsed: totalTokens,
            bucketCount: bucketCount,
            lastBucket: lastBucket
        )
    }

    func fetchAnthropicUsageSummary(apiKey: String, period: DateInterval) async throws -> TokenUsageSummary {
        var totalTokens = 0
        var bucketCount = 0
        var lastBucket: DateInterval?
        var nextPage: String?
        repeat {
            var parameters = anthropicQueryParameters(period: period)
            if let nextPage {
                parameters["page"] = nextPage
            }

            let request = NetworkRequest.get(
                "https://api.anthropic.com/v1/organizations/usage_report/messages",
                queryParameters: parameters,
                headers: [
                    "anthropic-version": "2023-06-01",
                    "content-type": "application/json",
                    "x-api-key": apiKey
                ]
            )

            let response: AnthropicUsageResponse = try await anthropicManager.execute(
                request,
                responseType: AnthropicUsageResponse.self,
                decoder: Self.anthropicDecoder
            )

            totalTokens += response.totalTokens
            bucketCount += response.data.count
            lastBucket = lastBucketInterval(current: lastBucket, next: response.lastBucketInterval)
            nextPage = response.nextPage
        } while nextPage != nil

        return TokenUsageSummary(
            tokensUsed: totalTokens,
            bucketCount: bucketCount,
            lastBucket: lastBucket
        )
    }
}

private extension TokenUsageAPIClient {
    func openAIQueryParameters(period: DateInterval) -> [String: String] {
        [
            "start_time": "\(Int(period.start.timeIntervalSince1970))",
            "end_time": "\(Int(period.end.timeIntervalSince1970))",
            "bucket_width": "1d",
            "limit": "31"
        ]
    }

    func anthropicQueryParameters(period: DateInterval) -> [String: String] {
        [
            "starting_at": Self.iso8601Formatter.string(from: period.start),
            "ending_at": Self.iso8601Formatter.string(from: period.end),
            "bucket_width": "1d",
            "limit": "31"
        ]
    }

    func lastBucketInterval(
        current: DateInterval?,
        next: DateInterval?
    ) -> DateInterval? {
        guard let next else {
            return current
        }
        guard let current else {
            return next
        }
        return next.end > current.end ? next : current
    }

    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static let iso8601FractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static let anthropicDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            if let date = iso8601FractionalFormatter.date(from: value) {
                return date
            }
            if let date = iso8601Formatter.date(from: value) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(value)"
            )
        }
        return decoder
    }()
}

private struct OpenAIUsageResponse: Decodable {
    let data: [OpenAIUsageBucket]
    let nextPage: String?

    private enum CodingKeys: String, CodingKey {
        case data
        case nextPage = "next_page"
    }

    var totalTokens: Int {
        data.reduce(0) { $0 + $1.totalTokens }
    }

    var lastBucketInterval: DateInterval? {
        data.map(\.interval).max(by: { $0.end < $1.end })
    }
}

private struct OpenAIUsageBucket: Decodable {
    let startTime: Int
    let endTime: Int
    let results: [OpenAIUsageResult]

    private enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case results
    }

    var totalTokens: Int {
        results.reduce(0) { $0 + $1.totalTokens }
    }

    var interval: DateInterval {
        DateInterval(
            start: Date(timeIntervalSince1970: TimeInterval(startTime)),
            end: Date(timeIntervalSince1970: TimeInterval(endTime))
        )
    }
}

private struct OpenAIUsageResult: Decodable {
    let inputTokens: Int?
    let outputTokens: Int?
    let inputCachedTokens: Int?
    let inputAudioTokens: Int?
    let outputAudioTokens: Int?

    private enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case inputCachedTokens = "input_cached_tokens"
        case inputAudioTokens = "input_audio_tokens"
        case outputAudioTokens = "output_audio_tokens"
    }

    var totalTokens: Int {
        (inputTokens ?? 0)
        + (outputTokens ?? 0)
        + (inputCachedTokens ?? 0)
        + (inputAudioTokens ?? 0)
        + (outputAudioTokens ?? 0)
    }
}

private struct AnthropicUsageResponse: Decodable {
    let data: [AnthropicUsageBucket]
    let hasMore: Bool
    let nextPage: String?

    private enum CodingKeys: String, CodingKey {
        case data
        case hasMore = "has_more"
        case nextPage = "next_page"
    }

    var totalTokens: Int {
        data.reduce(0) { $0 + $1.totalTokens }
    }

    var lastBucketInterval: DateInterval? {
        data.map(\.interval).max(by: { $0.end < $1.end })
    }
}

private struct AnthropicUsageBucket: Decodable {
    let startingAt: Date
    let endingAt: Date
    let results: [AnthropicUsageResult]

    private enum CodingKeys: String, CodingKey {
        case startingAt = "starting_at"
        case endingAt = "ending_at"
        case results
    }

    var totalTokens: Int {
        results.reduce(0) { $0 + $1.totalTokens }
    }

    var interval: DateInterval {
        DateInterval(start: startingAt, end: endingAt)
    }
}

private struct AnthropicUsageResult: Decodable {
    let uncachedInputTokens: Double?
    let cacheReadInputTokens: Double?
    let cacheCreation: AnthropicCacheCreation?
    let outputTokens: Double?

    private enum CodingKeys: String, CodingKey {
        case uncachedInputTokens = "uncached_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case cacheCreation = "cache_creation"
        case outputTokens = "output_tokens"
    }

    var totalTokens: Int {
        let cacheCreationTokens = (cacheCreation?.ephemeral1hInputTokens ?? 0)
            + (cacheCreation?.ephemeral5mInputTokens ?? 0)

        let total = (uncachedInputTokens ?? 0)
            + (cacheReadInputTokens ?? 0)
            + cacheCreationTokens
            + (outputTokens ?? 0)

        return Int(total.rounded())
    }
}

private struct AnthropicCacheCreation: Decodable {
    let ephemeral1hInputTokens: Double?
    let ephemeral5mInputTokens: Double?

    private enum CodingKeys: String, CodingKey {
        case ephemeral1hInputTokens = "ephemeral_1h_input_tokens"
        case ephemeral5mInputTokens = "ephemeral_5m_input_tokens"
    }
}
