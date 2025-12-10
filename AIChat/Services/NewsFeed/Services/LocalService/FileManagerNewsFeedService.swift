//
//  FileManagerNewsFeedService.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

final class FileManagerNewsFeedService: LocalNewsFeedServiceProtocol, @unchecked Sendable {

    private let fileManager = FileManager.default
    private let cacheFileName = "cached_news.json"

    private var cacheFileURL: URL? {
        guard let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(cacheFileName)
    }

    func saveNews(_ articles: [NewsArticle]) throws {
        guard let fileURL = cacheFileURL else {
            throw NewsFeedError.invalidURL
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(articles)

        try data.write(to: fileURL, options: .atomic)
    }

    func fetchCachedNews() throws -> [NewsArticle] {
        guard let fileURL = cacheFileURL else {
            throw NewsFeedError.invalidURL
        }

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let articles = try decoder.decode([NewsArticle].self, from: data)

        return articles
    }

    func clearCache() throws {
        guard let fileURL = cacheFileURL else {
            throw NewsFeedError.invalidURL
        }

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
