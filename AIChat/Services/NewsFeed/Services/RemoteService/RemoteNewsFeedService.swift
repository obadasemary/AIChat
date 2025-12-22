//
//  RemoteNewsFeedService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

final class RemoteNewsFeedService: RemoteNewsFeedServiceProtocol {

    private let apiKey: String
    private let baseURL = "https://newsapi.org/v2"

    init(apiKey: String = Keys.newsAPIKey) {
        self.apiKey = apiKey
    }

    func fetchNews(category: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        var urlString = "\(baseURL)/everything?sortBy=publishedAt&page=\(page)&pageSize=\(pageSize)"

        if let language = language {
            urlString += "&language=\(language)"
        }

        if let category = category {
            urlString += "&q=\(category)"
        }

        guard let url = URL(string: urlString) else {
            throw NewsFeedError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsFeedError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)

        let articles = apiResponse.articles.map { apiArticle in
            NewsArticle(
                id: apiArticle.url.sha256(),
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

    func fetchTopHeadlines(country: String?, language: String?, page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        var urlString = "\(baseURL)/top-headlines?page=\(page)&pageSize=\(pageSize)"

        // Note: News API doesn't support both country and language together for top-headlines
        // Country takes precedence as it returns news in that country's primary language
        if let country = country {
            urlString += "&country=\(country)"
        } else if let language = language {
            // Only use language if country is not specified
            urlString += "&language=\(language)"
        }

        guard let url = URL(string: urlString) else {
            throw NewsFeedError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsFeedError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)

        let articles = apiResponse.articles.map { apiArticle in
            NewsArticle(
                id: apiArticle.url.sha256(),
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
