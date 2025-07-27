//
//  ChatRowCellUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol ChatRowCellUseCaseProtocol {
    var auth: UserAuthInfo? { get }
    func getAvatar(id: String) async throws -> AvatarModel?
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func trackEvent(event: any LoggableEvent)
}
