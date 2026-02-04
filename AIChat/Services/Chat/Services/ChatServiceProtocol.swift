//
//  ChatServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

protocol ChatServiceProtocol: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAllChats(userId: String) async throws -> [ChatModel]
    func addChatMessage(message: ChatMessageModel) async throws
    func updateChatMessage(message: ChatMessageModel) async throws
    func updateMessageReaction(chatId: String, messageId: String, reactions: [String: MessageReaction]) async throws
    func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws
    @MainActor func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error>
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(report: ChatReportModel) async throws
}
