//
//  AnyChatRowCellInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
struct AnyChatRowCellInteractor: ChatRowCellInteractorProtocol {
    
    let anyAuth: UserAuthInfo?
    let anyGetAvatar: (_ id: String) async throws -> AvatarModel?
    let anyGetLastChatMessage: (_ chatId: String) async throws -> ChatMessageModel?
    let anyTrackEvent: ((LoggableEvent) -> Void)?
    
    init(
        auth: UserAuthInfo? = .mock(),
        getAvatar: @escaping (_ id: String) async throws -> AvatarModel?,
        getLastChatMessage: @escaping (_ chatId: String) async throws -> ChatMessageModel?,
        trackEvent: ((LoggableEvent) -> Void)? = nil
    ) {
        self.anyAuth = auth
        self.anyGetAvatar = getAvatar
        self.anyGetLastChatMessage = getLastChatMessage
        self.anyTrackEvent = trackEvent
    }
    
    init(interactor: ChatRowCellInteractorProtocol) {
        self.anyAuth = interactor.auth
        self.anyGetAvatar = interactor.getAvatar
        self.anyGetLastChatMessage = interactor.getLastChatMessage
        self.anyTrackEvent = interactor.trackEvent
    }
    
    var auth: UserAuthInfo? {
        anyAuth
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await anyGetAvatar(id)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await anyGetLastChatMessage(chatId)
    }
    
    func trackEvent(event: any LoggableEvent) {
        anyTrackEvent?(event)
    }
}
