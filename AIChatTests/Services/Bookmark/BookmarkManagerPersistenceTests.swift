//
//  BookmarkManagerPersistenceTests.swift
//  AIChatTests
//
//  Created by Codex on 25.12.2025.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct BookmarkManagerPersistenceTests {

    @Test("Bookmarks persist across manager instances with same store URL")
    func testPersistenceAcrossInstances() async throws {
        // Create unique folder and store URL for isolation
        let storeDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BookmarkStore-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
        let storeURL = storeDirectory.appendingPathComponent("Bookmarks.store")

        // First instance: add a bookmark
        let manager = BookmarkManager(
            isStoredInMemoryOnly: false,
            storeName: "TestBookmarks",
            storeURL: storeURL
        )
        let article = NewsArticle.mock(title: "Persistent Article")
        manager.addBookmark(article)
        #expect(manager.getBookmarkedArticles().count == 1)

        // Second instance pointing to the same store should load the saved bookmark
        let reloadedManager = BookmarkManager(
            isStoredInMemoryOnly: false,
            storeName: "TestBookmarks",
            storeURL: storeURL
        )
        let loadedArticles = reloadedManager.getBookmarkedArticles()

        #expect(loadedArticles.count == 1)
        #expect(loadedArticles.first?.id == article.id)

        // Cleanup the temp store
        try? FileManager.default.removeItem(at: storeDirectory)
    }
}
