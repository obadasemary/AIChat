//
//  ChatManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

import Foundation

@MainActor
@Observable
final class ChatManager {
    
    private let service: ChatServiceProtocol
    
    init(service: ChatServiceProtocol) {
        self.service = service
    }
}

extension ChatManager: ChatManagerProtocol {
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await service.getAllChats(userId: userId)
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await service
            .addChatMessage(message: message)
    }

    func updateChatMessage(message: ChatMessageModel) async throws {
        try await service
            .updateChatMessage(message: message)
    }

    func updateMessageReaction(chatId: String, messageId: String, reactions: [String: MessageReaction]) async throws {
        try await service.updateMessageReaction(chatId: chatId, messageId: messageId, reactions: reactions)
    }

    func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await service
            .markChatMessagesAsSeen(
                chatId: chatId,
                messageId: messageId,
                userId: userId
            )
    }
    
    func streamChatMessages(
        chatId: String
    ) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        service
            .streamChatMessages(
                chatId: chatId
            )
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await service.deleteChat(chatId: chatId)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        try await service.deleteAllChatsForUser(userId: userId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        let report = ChatReportModel.new(chatId: chatId, userId: userId)
        
        try await service.reportChat(report: report)
    }
}
