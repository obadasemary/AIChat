//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.04.2025.
//

import Foundation

struct ChatMessageModel: Identifiable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds, !seenByIds.isEmpty else {
            return false
        }
        return seenByIds.contains(userId)
    }
    
    static func newUserMessage(
        chatId: String,
        userId: String,
        message: AIChatModel
    ) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCreated: .now
        )
    }
    
    static func newUAIMessage(
        chatId: String,
        avatarId: String,
        message: AIChatModel
    ) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: avatarId,
            content: message,
            seenByIds: [],
            dateCreated: .now
        )
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatMessageModel(
                id: "msg1",
                chatId: "1",
                authorId: "mock_user_id_1",
                content: AIChatModel(
                    role: .user,
                    message: "Hello, how are you?"
                ),
                seenByIds: ["user2", "user3"],
                dateCreated: now
            ),
            ChatMessageModel(
                id: "msg2",
                chatId: "2",
                authorId: "mock_user_id_2",
                content: AIChatModel(
                    role: .assistant,
                    message: "I'm doing well, thanks for asking!"
                ),
                seenByIds: ["user1"],
                dateCreated: now.addingTimeInterval(minutes: -5)
            ),
            ChatMessageModel(
                id: "msg3",
                chatId: "3",
                authorId: "mock_user_id_3",
                content: AIChatModel(
                    role: .assistant,
                    message: "Anyone up for a game tonight?"
                ),
                seenByIds: ["user1", "user2", "user4"],
                dateCreated: now.addingTimeInterval(hours: -1)
            ),
            ChatMessageModel(
                id: "msg4",
                chatId: "1",
                authorId: "mock_user_id_1",
                content: AIChatModel(
                    role: .user,
                    message: "Sure, count me in!"
                ),
                seenByIds: nil,
                dateCreated: now.addingTimeInterval(hours: -2, minutes: -15)
            )
        ]
    }
}
