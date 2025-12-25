//
//  BookmarkManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class BookmarkManager {
    
    // MARK: - Properties
    private let isStoredInMemoryOnly: Bool
    private let container: ModelContainer
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    private let legacyUserDefaults = UserDefaults.standard
    private let legacyBookmarksKey = "bookmarked_articles"
    private let legacyArticlesDataKey = "bookmarked_articles_data"
    
    // MARK: - Initialization
    init(
        isStoredInMemoryOnly: Bool = false,
        storeName: String = "Bookmarks",
        storeURL: URL? = nil
    ) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        do {
            if isStoredInMemoryOnly {
                let configuration = ModelConfiguration(
                    storeName,
                    isStoredInMemoryOnly: true
                )
                container = try ModelContainer(
                    for: BookmarkArticleEntity.self,
                    configurations: configuration
                )
            } else {
                let configuration: ModelConfiguration
                if let storeURL {
                    configuration = ModelConfiguration(storeName, url: storeURL)
                } else {
                    configuration = ModelConfiguration(storeName)
                }
                container = try ModelContainer(
                    for: BookmarkArticleEntity.self,
                    configurations: configuration
                )
            }
            if isStoredInMemoryOnly == false {
                migrateLegacyBookmarksIfNeeded()
            }
        } catch {
            fatalError("Failed to initialize BookmarkManager: \(error.localizedDescription)")
        }
    }
}

// MARK: - Public Methods

extension BookmarkManager: BookmarkManagerProtocol {
    
    func isBookmarked(articleId: String) -> Bool {
        do {
            return try fetchBookmarkEntity(articleId: articleId) != nil
        } catch {
            logStorageError("isBookmarked failed for \(articleId)", error)
            return false
        }
    }
    
    func addBookmark(_ article: NewsArticle) {
        do {
            if let existingEntity = try fetchBookmarkEntity(articleId: article.id) {
                existingEntity.update(from: article)
            } else {
                let entity = BookmarkArticleEntity(from: article)
                mainContext.insert(entity)
            }
            try mainContext.save()
        } catch {
            logStorageError("addBookmark failed for \(article.id)", error)
        }
    }
    
    func removeBookmark(articleId: String) {
        do {
            if let entity = try fetchBookmarkEntity(articleId: articleId) {
                mainContext.delete(entity)
                try mainContext.save()
            }
        } catch {
            logStorageError("removeBookmark failed for \(articleId)", error)
        }
    }
    
    func getAllBookmarks() -> Set<String> {
        do {
            let descriptor = FetchDescriptor<BookmarkArticleEntity>()
            let entities = try mainContext.fetch(descriptor)
            return Set(entities.map { $0.articleId })
        } catch {
            logStorageError("getAllBookmarks failed", error)
            return []
        }
    }
    
    func getBookmarkedArticles() -> [NewsArticle] {
        do {
            let descriptor = FetchDescriptor<BookmarkArticleEntity>(
                sortBy: [
                    SortDescriptor(\.dateAdded, order: .reverse),
                    SortDescriptor(\.publishedAt, order: .reverse)
                ]
            )
            let entities = try mainContext.fetch(descriptor)
            return entities.map { $0.toModel() }
        } catch {
            logStorageError("getBookmarkedArticles failed", error)
            return []
        }
    }
}

// MARK: - Private Methods

private extension BookmarkManager {
    
    func fetchBookmarkEntity(articleId: String) throws -> BookmarkArticleEntity? {
        var descriptor = FetchDescriptor<BookmarkArticleEntity>(
            predicate: #Predicate { entity in
                entity.articleId == articleId
            }
        )
        descriptor.fetchLimit = 1
        return try mainContext.fetch(descriptor).first
    }
    
    func migrateLegacyBookmarksIfNeeded() {
        guard let legacyData = legacyUserDefaults.data(forKey: legacyArticlesDataKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let legacyArticles = try decoder.decode([String: NewsArticle].self, from: legacyData)
            
            let existingIds = getAllBookmarks()
            
            legacyArticles.values.forEach { article in
                if existingIds.contains(article.id) == false {
                    addBookmark(article)
                }
            }
            
            legacyUserDefaults.removeObject(forKey: legacyBookmarksKey)
            legacyUserDefaults.removeObject(forKey: legacyArticlesDataKey)
        } catch {
            logStorageError("migrateLegacyBookmarksIfNeeded failed", error)
        }
    }
    
    func logStorageError(_ message: String, _ error: Error) {
#if DEBUG
        print("BookmarkManager Error - \(message): \(error)")
#endif
    }
}
