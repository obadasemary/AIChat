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
    
    nonisolated func streamChatMessages(
        chatId: String,
        onListenerConfigured: @escaping (ListenerRegistration) -> Void
    ) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        service
            .streamChatMessages(
                chatId: chatId,
                onListenerConfigured: onListenerConfigured
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
