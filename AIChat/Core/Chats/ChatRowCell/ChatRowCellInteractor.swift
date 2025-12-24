//
//  ChatRowCellInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class ChatRowCellInteractor {
    
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for ChatRowCellInteractor")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for ChatRowCellInteractor")
        }
        guard let chatManager = container.resolve(ChatManager.self) else {
            preconditionFailure("Failed to resolve ChatManager for ChatRowCellInteractor")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for ChatRowCellInteractor")
        }
        
        self.authManager = authManager
        self.avatarManager = avatarManager
        self.chatManager = chatManager
        self.logManager = logManager
    }
}

extension ChatRowCellInteractor: ChatRowCellInteractorProtocol {
    
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
