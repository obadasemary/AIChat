//
//  ChatServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

protocol ChatServiceProtocol: Sendable {
    func createNewChat(chat: ChatModel) async throws
}
