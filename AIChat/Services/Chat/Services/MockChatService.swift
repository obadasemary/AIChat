//
//  MockChatService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

import Foundation

struct MockChatService {
    
    let chats: [ChatModel]
    let delay: Double
    let showError: Bool
    
    init(
        chats: [ChatModel] = ChatModel.mocks,
        delay: Double = 0.0,
        showError: Bool = false
    ) {
        self.chats = chats
        self.delay = delay
        self.showError = showError
    }
}

extension MockChatService: ChatServiceProtocol {
    
    func createNewChat(chat: ChatModel) async throws {}
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return chats.first { chat in
            chat.userId == userId && chat.avatarId == avatarId
        }
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return chats
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {}
    
    func streamChatMessages(
        chatId: String,
        onListenerConfigured: @escaping (ListenerRegistration) -> Void
    ) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        AsyncThrowingStream { continuation in }
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ChatMessageModel.mocks.randomElement()
    }
    
    func deleteChat(chatId: String) async throws {}
    
    func deleteAllChatsForUser(userId: String) async throws {}
    
}

private extension MockChatService {
    func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
