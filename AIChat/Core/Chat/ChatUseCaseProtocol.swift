//
//  ChatUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol ChatUseCaseProtocol {
    
    var currentUser: UserModel? { get }
    var auth: UserAuthInfo? { get }
    var isPremium: Bool { get }
    
    // Avatar
    func getAuthId() throws -> String
    func getAvatar(id: String) async throws -> AvatarModel?
    func addRecentAvatar(avatar: AvatarModel) async throws
    
    // Chat
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error>
    func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(message: ChatMessageModel) async throws
    func reportChat(chatId: String, userId: String) async throws
    func deleteChat(chatId: String) async throws
    
    // AI
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
    
    func trackEvent(event: any LoggableEvent)
}
