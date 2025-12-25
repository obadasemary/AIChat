//
//  ChatRowCellPresenter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@Observable
@MainActor
final class ChatRowCellPresenter {
    
    private let chatRowCellInteractor: ChatRowCellInteractorProtocol
    
    private(set) var avatar: AvatarModel?
    private(set) var lastChatMessage: ChatMessageModel?
    private(set) var didLoadAvatar: Bool = false
    private(set) var didLoadLastChatMessage: Bool = false
    
     var isLoading: Bool {
        !didLoadAvatar && !didLoadLastChatMessage
    }
    
    var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId = chatRowCellInteractor.auth?.uid else {
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
    
    init(chatRowCellInteractor: ChatRowCellInteractorProtocol) {
        self.chatRowCellInteractor = chatRowCellInteractor
    }
}

extension ChatRowCellPresenter {
    
    func loadAvatar(chat: ChatModel) async {
        avatar = try? await chatRowCellInteractor.getAvatar(id: chat.avatarId)
        didLoadAvatar = true
    }
    
    func loadLastChatMessage(chat: ChatModel) async {
        lastChatMessage = try? await chatRowCellInteractor
            .getLastChatMessage(chatId: chat.id)
        didLoadLastChatMessage = true
    }
}
