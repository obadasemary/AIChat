//
//  RemoteNewsFeedService.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

final class RemoteNewsFeedService: RemoteNewsFeedServiceProtocol {

    private let apiKey: String
    private let baseURL = "https://newsapi.org/v2"

    init(apiKey: String = Keys.newsAPIKey) {
        self.apiKey = apiKey
    }

    func fetchNews(category: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        var urlString = "\(baseURL)/everything?apiKey=\(apiKey)&sortBy=publishedAt&page=\(page)&pageSize=\(pageSize)"

        if let category = category {
            urlString += "&q=\(category)"
        }

        guard let url = URL(string: urlString) else {
            throw NewsFeedError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsFeedError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)

        let articles = apiResponse.articles.map { apiArticle in
            NewsArticle(
                id: UUID().uuidString,
                title: apiArticle.title,
                description: apiArticle.description,
                content: apiArticle.content,
                author: apiArticle.author,
                source: NewsSource(
                    id: apiArticle.source.id,
                    name: apiArticle.source.name
                ),
                url: apiArticle.url,
                imageUrl: apiArticle.urlToImage,
                publishedAt: apiArticle.publishedAt,
                category: nil
            )
        }

        return NewsFeedResponse(
            articles: articles,
            totalResults: apiResponse.totalResults
        )
    }

    func fetchTopHeadlines(country: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        var urlString = "\(baseURL)/top-headlines?apiKey=\(apiKey)&page=\(page)&pageSize=\(pageSize)"

        if let country = country {
            urlString += "&country=\(country)"
        }

        guard let url = URL(string: urlString) else {
            throw NewsFeedError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsFeedError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)

        let articles = apiResponse.articles.map { apiArticle in
            NewsArticle(
                id: UUID().uuidString,
                title: apiArticle.title,
                description: apiArticle.description,
                content: apiArticle.content,
                author: apiArticle.author,
                source: NewsSource(
                    id: apiArticle.source.id,
                    name: apiArticle.source.name
                ),
                url: apiArticle.url,
                imageUrl: apiArticle.urlToImage,
                publishedAt: apiArticle.publishedAt,
                category: nil
            )
        }

        return NewsFeedResponse(
            articles: articles,
            totalResults: apiResponse.totalResults
        )
    }
}

// MARK: - API Response Models
private struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [APIArticle]
}

private struct APIArticle: Codable {
    let source: APISource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let content: String?
}

private struct APISource: Codable {
    let id: String?
    let name: String
}

// MARK: - Errors
enum NewsFeedError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError:
            return "Network error occurred"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
