//
//  ChatsUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 26.07.2025.
//

import Foundation

@MainActor
protocol ChatsUseCaseProtocol {
    func getAuthId() async throws -> String
    func getRecentAvatars() throws -> [AvatarModel]
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getAvatar(id: String) async throws -> AvatarModel?
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func trackEvent(event: any LoggableEvent)
}
