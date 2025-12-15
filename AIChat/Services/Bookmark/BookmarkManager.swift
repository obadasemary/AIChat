//
//  BookmarkManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation

@MainActor
@Observable
final class BookmarkManager {
    
    // MARK: - Properties
    private var bookmarkedArticleIds: Set<String> = []
    private var bookmarkedArticlesData: [String: NewsArticle] = [:]
    private let userDefaults = UserDefaults.standard
    private let bookmarksKey = "bookmarked_articles"
    private let articlesDataKey = "bookmarked_articles_data"
    
    // MARK: - Initialization
    init() {
        loadBookmarks()
    }
}

// MARK: - Public Methods

extension BookmarkManager: BookmarkManagerProtocol {
    
    func isBookmarked(articleId: String) -> Bool {
        bookmarkedArticleIds.contains(articleId)
    }
    
    func addBookmark(_ article: NewsArticle) {
        bookmarkedArticleIds.insert(article.id)
        bookmarkedArticlesData[article.id] = article
        saveBookmarks()
    }
    
    func removeBookmark(articleId: String) {
        bookmarkedArticleIds.remove(articleId)
        bookmarkedArticlesData.removeValue(forKey: articleId)
        saveBookmarks()
    }
    
    func getAllBookmarks() -> Set<String> {
        bookmarkedArticleIds
    }
    
    func getBookmarkedArticles() -> [NewsArticle] {
        return Array(bookmarkedArticlesData.values).sorted { article1, article2 in
            article1.publishedAt > article2.publishedAt
        }
    }
}
    
// MARK: - Private Methods

private extension BookmarkManager {

    func loadBookmarks() {
        if let bookmarkIds = userDefaults.stringArray(forKey: bookmarksKey) {
            bookmarkedArticleIds = Set(bookmarkIds)
        }

        if let articlesData = userDefaults.data(forKey: articlesDataKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                bookmarkedArticlesData = try decoder.decode([String: NewsArticle].self, from: articlesData)
            } catch {
                #if DEBUG
                print("Failed to decode bookmarked articles: \(error)")
                #endif
                bookmarkedArticlesData = [:]
            }
        }
    }

    func saveBookmarks() {
        userDefaults.set(Array(bookmarkedArticleIds), forKey: bookmarksKey)

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let articlesData = try encoder.encode(bookmarkedArticlesData)
            userDefaults.set(articlesData, forKey: articlesDataKey)
        } catch {
            #if DEBUG
            print("Failed to encode bookmarked articles: \(error)")
            #endif
        }
    }
}
