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
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
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
