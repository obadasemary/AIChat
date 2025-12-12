//
//  LocalNewsFeedServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

protocol LocalNewsFeedServiceProtocol: Sendable {
    func saveNews(_ articles: [NewsArticle]) throws
    func fetchCachedNews() throws -> [NewsArticle]
    func clearCache() throws
}
