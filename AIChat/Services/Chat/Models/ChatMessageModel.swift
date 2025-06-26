//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.04.2025.
//

import Foundation
import IdentifiableByString

struct ChatMessageModel: Identifiable, Codable, StringIdentifiable {
    
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case dateCreated = "date_created"
    }
    
    var eventParameters: [String: Any] {
        var dict: [String: Any?] = [
            "message_\(CodingKeys.id.rawValue)": id,
            "message_\(CodingKeys.chatId.rawValue)": chatId,
            "message_\(CodingKeys.authorId.rawValue)": authorId,
            "message_\(CodingKeys.seenByIds.rawValue)": seenByIds?.sorted().joined(separator: ","),
            "message_\(CodingKeys.dateCreated.rawValue)": dateCreated
        ]
        dict.merge(content?.eventParameters)
        return dict.compactMapValues { $0 }
    }
    
    var dateCreatedCalculated: Date {
        dateCreated ?? .distantPast
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
                authorId: UserAuthInfo.mock().uid,
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
                authorId: AvatarModel.mock.avatarId,
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
                authorId: UserAuthInfo.mock().uid,
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
                authorId: AvatarModel.mock.avatarId,
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
