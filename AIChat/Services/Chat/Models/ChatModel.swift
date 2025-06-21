//
//  ChatModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.04.2025.
//

import Foundation
import IdentifiableByString

struct ChatModel: Identifiable, Codable, StringIdentifiable {
    
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
    init(
        id: String,
        userId: String,
        avatarId: String,
        dateCreated: Date,
        dateModified: Date
    ) {
        self.id = id
        self.userId = userId
        self.avatarId = avatarId
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
    
    static func chatId(
        userId: String,
        avatarId: String
    ) -> String {
        "\(userId)_\(avatarId)"
    }
    
    static func new(
        userId: String,
        avatarId: String
    ) -> Self {
        ChatModel(
            id: chatId(userId: userId, avatarId: avatarId),
            userId: userId,
            avatarId: avatarId,
            dateCreated: .now,
            dateModified: .now
        )
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(
                id: "mock_chat_1",
                userId: "user_001",
                avatarId: "avatar_001",
                dateCreated: now,
                dateModified: now
            ),
            ChatModel(
                id: "chat_002",
                userId: "user_002",
                avatarId: "avatar_002",
                dateCreated: now.addingTimeInterval(
                    hours: -1
                ),
                dateModified: now.addingTimeInterval(
                    minutes: -30
                )
            ),
            ChatModel(
                id: "chat_003",
                userId: "user_003",
                avatarId: "avatar_003",
                dateCreated: now.addingTimeInterval(
                    hours: -2
                ),
                dateModified: now.addingTimeInterval(
                    hours: -1
                )
            ),
            ChatModel(
                id: "chat_004",
                userId: "user_004",
                avatarId: "avatar_004",
                dateCreated: now.addingTimeInterval(
                    days: -1
                ),
                dateModified: now.addingTimeInterval(
                    hours: -10
                )
            )
        ]
    }
}
