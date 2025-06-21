//
//  ChatManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

protocol ChatManagerProtocol {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAllChats(userId: String) async throws -> [ChatModel]
    func addChatMessage(message: ChatMessageModel) async throws
    func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws
    @MainActor func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error>
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(chatId: String, userId: String) async throws
}
