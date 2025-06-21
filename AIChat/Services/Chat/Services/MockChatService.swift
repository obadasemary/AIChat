//
//  MockChatService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

struct MockChatService {}

extension MockChatService: ChatServiceProtocol {
    
    func createNewChat(chat: ChatModel) async throws {}
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        ChatModel.mock
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {}
    
    func streamChatMessages(
        chatId: String,
        onListenerConfigured: @escaping (ListenerRegistration) -> Void
    ) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        AsyncThrowingStream { continuation in }
    }
}
