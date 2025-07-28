//
//  ChatUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class ChatUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
    }
}

extension ChatUseCase: ChatUseCaseProtocol {
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    var isPremium: Bool {
        purchaseManager.entitlements.hasActiveEntitlement
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await avatarManager.getAvatar(id: id)
    }
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try await avatarManager.addRecentAvatar(avatar: avatar)
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await chatManager.getChat(userId: userId, avatarId: avatarId)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        chatManager.streamChatMessages(chatId: chatId)
    }
    
    func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await chatManager
            .markChatMessagesAsSeen(
                chatId: chatId,
                messageId: messageId,
                userId: userId
            )
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await chatManager.createNewChat(chat: chat)
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await chatManager.addChatMessage(message: message)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        try await chatManager.reportChat(chatId: chatId, userId: userId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await chatManager.deleteChat(chatId: chatId)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
