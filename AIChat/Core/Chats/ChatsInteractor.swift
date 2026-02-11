//
//  ChatsInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 26.07.2025.
//

import Foundation

@MainActor
protocol ChatsInteractorProtocol {
    func getAuthId() async throws -> String
    func getRecentAvatars() throws -> [AvatarModel]
    func getAllChats(userId: String) async throws -> [ChatModel]
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class ChatsInteractor {
    
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for ChatsInteractor")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for ChatsInteractor")
        }
        guard let chatManager = container.resolve(ChatManager.self) else {
            preconditionFailure("Failed to resolve ChatManager for ChatsInteractor")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for ChatsInteractor")
        }
        
        self.authManager = authManager
        self.avatarManager = avatarManager
        self.chatManager = chatManager
        self.logManager = logManager
    }
}

extension ChatsInteractor: ChatsInteractorProtocol {
    
    func getAuthId() async throws -> String {
        try authManager.getAuthId()
    }

    func getRecentAvatars() throws -> [AvatarModel] {
        try avatarManager.getRecentAvatars()
    }

    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await chatManager.getAllChats(userId: userId)
    }

    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
