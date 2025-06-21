//
//  ChatServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

protocol ChatServiceProtocol: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func addChatMessage(message: ChatMessageModel) async throws
    func streamChatMessages(
        chatId: String,
        onListenerConfigured: @escaping (ListenerRegistration) -> Void
    ) -> AsyncThrowingStream<[ChatMessageModel], any Error>
}
