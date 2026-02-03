//
//  MessageKitDataAdapter.swift
//  AIChat
//
//  Created by Claude on 03.02.2026.
//

import Foundation
import MessageKit

// MARK: - Sender Implementation
struct MessageKitSender: SenderType {
    let senderId: String
    let displayName: String
}

// MARK: - Message Implementation
struct MessageKitMessage: MessageType {
    let messageId: String
    let sender: SenderType
    let sentDate: Date
    let kind: MessageKind

    init(chatMessage: ChatMessageModel, currentUserId: String, avatarName: String) {
        self.messageId = chatMessage.id
        self.sentDate = chatMessage.dateCreatedCalculated

        // Determine sender - handle optional authorId
        let authorId = chatMessage.authorId ?? "unknown"
        let isCurrentUser = authorId == currentUserId
        self.sender = MessageKitSender(
            senderId: authorId,
            displayName: isCurrentUser ? "You" : avatarName
        )

        // Determine message kind - handle optional content
        let messageText = chatMessage.content?.message ?? ""
        self.kind = .text(messageText)
    }
}

// MARK: - ChatMessageModel Extension
extension ChatMessageModel {
    func toMessageKitMessage(currentUserId: String, avatarName: String) -> MessageKitMessage {
        MessageKitMessage(chatMessage: self, currentUserId: currentUserId, avatarName: avatarName)
    }
}
