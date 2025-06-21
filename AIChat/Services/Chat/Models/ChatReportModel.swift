//
//  ChatReportModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.06.2025.
//

import Foundation
import IdentifiableByString

struct ChatReportModel: Codable, StringIdentifiable {
    
    let id: String
    let chatId: String
    let userId: String
    let isActive: Bool
    let dateCreated: Date
    
    init(
        id: String,
        chatId: String,
        userId: String,
        isActive: Bool,
        dateCreated: Date
    ) {
        self.id = id
        self.chatId = chatId
        self.userId = userId
        self.isActive = isActive
        self.dateCreated = dateCreated
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case userId = "user_id"
        case isActive = "is_active"
        case dateCreated = "date_created"
    }
    
    static func new(chatId: String, userId: String) -> Self {
        ChatReportModel(
            id: UUID().uuidString,
            chatId: chatId,
            userId: userId,
            isActive: true,
            dateCreated: .now
        )
    }
}
