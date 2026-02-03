//
//  ChatUseCase.swift
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
    func updateMessageReaction(chatId: String, messageId: String, reactions: [String: MessageReaction]) async throws
    func reportChat(chatId: String, userId: String) async throws
    func deleteChat(chatId: String) async throws
    
    // AI
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
    
    func trackEvent(event: any LoggableEvent)
}

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
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for ChatUseCase")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for ChatUseCase")
        }
        guard let aiManager = container.resolve(AIManager.self) else {
            preconditionFailure("Failed to resolve AIManager for ChatUseCase")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for ChatUseCase")
        }
        guard let chatManager = container.resolve(ChatManager.self) else {
            preconditionFailure("Failed to resolve ChatManager for ChatUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for ChatUseCase")
        }
        guard let purchaseManager = container.resolve(PurchaseManager.self) else {
            preconditionFailure("Failed to resolve PurchaseManager for ChatUseCase")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.aiManager = aiManager
        self.avatarManager = avatarManager
        self.chatManager = chatManager
        self.logManager = logManager
        self.purchaseManager = purchaseManager
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

    func updateMessageReaction(chatId: String, messageId: String, reactions: [String: MessageReaction]) async throws {
        try await chatManager.updateMessageReaction(chatId: chatId, messageId: messageId, reactions: reactions)
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
