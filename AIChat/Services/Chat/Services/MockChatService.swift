//
//  MockChatService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

struct MockChatService {}

extension MockChatService: ChatServiceProtocol {
    
    func createNewChat(chat: ChatModel) async throws {}
    
    func addChatMessage(message: ChatMessageModel) async throws {}
}
