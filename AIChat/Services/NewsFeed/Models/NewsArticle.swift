//
//  NewsArticle.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
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
        id: String? = nil,
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
            id: id ?? url.sha256(),
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

    static var mocks: [NewsArticle] {
        [
            mock(
                id: "1",
                title: "AI Revolution: New Breakthroughs in Machine Learning",
                description: "Scientists achieve unprecedented results in neural network training",
                content: "A team of researchers has developed a new approach to machine learning...",
                category: "Technology"
            ),
            mock(
                id: "2",
                title: "Climate Summit Reaches Historic Agreement",
                description: "World leaders commit to ambitious carbon reduction targets",
                content: "At the international climate summit, representatives from 195 countries...",
                category: "Environment"
            ),
            mock(
                id: "3",
                title: "Space Exploration Milestone Achieved",
                description: "First successful test of new propulsion system",
                content: "NASA announces a major breakthrough in spacecraft propulsion technology...",
                category: "Science"
            )
        ]
    }
}
