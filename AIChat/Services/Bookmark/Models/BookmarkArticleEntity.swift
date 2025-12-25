//
//  BookmarkArticleEntity.swift
//  AIChat
//
//  Created by Codex on 01.02.2026.
//

import Foundation
import SwiftData

@Model
final class BookmarkArticleEntity {

    @Attribute(.unique) var articleId: String
    var title: String
    var articleDescription: String?
    var content: String?
    var author: String?
    var sourceId: String?
    var sourceName: String
    var url: String
    var imageUrl: String?
    var publishedAt: Date
    var category: String?
    var dateAdded: Date

    init(from article: NewsArticle) {
        self.articleId = article.id
        self.title = article.title
        self.articleDescription = article.description
        self.content = article.content
        self.author = article.author
        self.sourceId = article.source.id
        self.sourceName = article.source.name
        self.url = article.url
        self.imageUrl = article.imageUrl
        self.publishedAt = article.publishedAt
        self.category = article.category
        self.dateAdded = .now
    }

    func update(from article: NewsArticle) {
        title = article.title
        articleDescription = article.description
        content = article.content
        author = article.author
        sourceId = article.source.id
        sourceName = article.source.name
        url = article.url
        imageUrl = article.imageUrl
        publishedAt = article.publishedAt
        category = article.category
    }

    func toModel() -> NewsArticle {
        NewsArticle(
            id: articleId,
            title: title,
            description: articleDescription,
            content: content,
            author: author,
            source: NewsSource(id: sourceId, name: sourceName),
            url: url,
            imageUrl: imageUrl,
            publishedAt: publishedAt,
            category: category
        )
    }
}
