//
//  NewsSource.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation

struct NewsSource: Codable, Equatable {
    let id: String?
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

extension NewsSource {
    static func mock(
        id: String? = "mock-source",
        name: String = "Mock News Source"
    ) -> NewsSource {
        NewsSource(id: id, name: name)
    }
}
