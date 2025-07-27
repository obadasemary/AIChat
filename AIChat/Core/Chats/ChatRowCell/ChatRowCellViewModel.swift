//
//  ChatRowCellViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@Observable
@MainActor
final class ChatRowCellViewModel {
    
    private let chatRowCellUseCase: ChatRowCellUseCaseProtocol
    
    private(set) var avatar: AvatarModel?
    private(set) var lastChatMessage: ChatMessageModel?
    private(set) var didLoadAvatar: Bool = false
    private(set) var didLoadLastChatMessage: Bool = false
    
     var isLoading: Bool {
        !didLoadAvatar && !didLoadLastChatMessage
    }
    
    var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId = chatRowCellUseCase.auth?.uid else {
            return false
        }
        return !lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
    
    var subheadline: String? {
        if isLoading {
            return "XXXX XXXX XXXX XXXX"
        }
        
        if avatar == nil && lastChatMessage == nil {
            return "Error"
        }
        
        return lastChatMessage?.content?.message
    }
    
    init(chatRowCellUseCase: ChatRowCellUseCaseProtocol) {
        self.chatRowCellUseCase = chatRowCellUseCase
    }
}

extension ChatRowCellViewModel {
    
    func loadAvatar(chat: ChatModel) async {
        avatar = try? await chatRowCellUseCase.getAvatar(id: chat.avatarId)
        didLoadAvatar = true
    }
    
    func loadLastChatMessage(chat: ChatModel) async {
        lastChatMessage = try? await chatRowCellUseCase
            .getLastChatMessage(chatId: chat.id)
        didLoadLastChatMessage = true
    }
}
