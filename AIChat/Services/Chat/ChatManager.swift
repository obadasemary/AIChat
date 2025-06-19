//
//  ChatManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

import Foundation

@MainActor
@Observable
final class ChatManager {
    
    private let service: ChatServiceProtocol
    
    init(service: ChatServiceProtocol) {
        self.service = service
    }
}

extension ChatManager: ChatManagerProtocol {
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
}
