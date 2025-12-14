//
//  BookmarkManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import Foundation

@MainActor
protocol BookmarkManagerProtocol {
    func isBookmarked(articleId: String) -> Bool
    func addBookmark(_ article: NewsArticle)
    func removeBookmark(articleId: String)
    func getAllBookmarks() -> Set<String>
    func getBookmarkedArticles() -> [NewsArticle]
}
