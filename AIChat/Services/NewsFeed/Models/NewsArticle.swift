//
//  NewsArticle.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

struct NewsArticle: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String?
    let content: String?
    let author: String?
    let source: NewsSource
    let url: String
    let imageUrl: String?
    let publishedAt: Date
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case author
        case source
        case url
        case imageUrl = "image_url"
        case publishedAt = "published_at"
        case category
    }
}

extension NewsArticle {
    static func mock(
        id: String = UUID().uuidString,
        title: String = "Sample News Article",
        description: String? = "This is a sample news description",
        content: String? = "This is the full content of the news article",
        author: String? = "John Doe",
        source: NewsSource = .mock(),
        url: String = "https://example.com/article",
        imageUrl: String? = "https://example.com/image.jpg",
        publishedAt: Date = Date(),
        category: String? = "Technology"
    ) -> NewsArticle {
        NewsArticle(
            id: id,
            title: title,
            description: description,
            content: content,
            author: author,
            source: source,
            url: url,
            imageUrl: imageUrl,
            publishedAt: publishedAt,
            category: category
        )
    }
}
