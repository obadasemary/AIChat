//
//  ChatRowCellUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class ChatRowCellUseCase {
    
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            fatalError("Failed to resolve AuthManager for ChatRowCellUseCase")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            fatalError("Failed to resolve AvatarManager for ChatRowCellUseCase")
        }
        guard let chatManager = container.resolve(ChatManager.self) else {
            fatalError("Failed to resolve ChatManager for ChatRowCellUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            fatalError("Failed to resolve LogManager for ChatRowCellUseCase")
        }
        
        self.authManager = authManager
        self.avatarManager = avatarManager
        self.chatManager = chatManager
        self.logManager = logManager
    }
}

extension ChatRowCellUseCase: ChatRowCellUseCaseProtocol {
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await avatarManager.getAvatar(id: id)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatId: chatId)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
