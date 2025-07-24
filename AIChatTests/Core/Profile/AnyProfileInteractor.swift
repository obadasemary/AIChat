//
//  AnyProfileInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.07.2025.
//

import Foundation
@testable import AIChat

@MainActor
struct AnyProfileInteractor: ProfileInteractor {
    
    let anyCurrentUser: UserModel?
    let anyGetAuthId: () throws -> String
    let anyGetAvatarsForAuthor: (_ userId: String) async throws -> [AIChat.AvatarModel]
    let anyRemoveAuthorIdFromAvatar: (_ avatarId: String) async throws -> Void
    let anyTrackEvent: (LoggableEvent) -> Void
    
    init(
        currentUser: UserModel?,
        getAuthId: @escaping () throws -> String,
        getAvatarsForAuthor: @escaping (_: String) async throws -> [AIChat.AvatarModel],
        removeAuthorIdFromAvatar: @escaping (_: String) async throws -> Void,
        trackEvent: @escaping (LoggableEvent) -> Void
    ) {
        self.anyCurrentUser = currentUser
        self.anyGetAuthId = getAuthId
        self.anyGetAvatarsForAuthor = getAvatarsForAuthor
        self.anyRemoveAuthorIdFromAvatar = removeAuthorIdFromAvatar
        self.anyTrackEvent = trackEvent
    }
    
    init(interactor: ProfileInteractor) {
        anyCurrentUser = interactor.currentUser
        anyGetAuthId = interactor.getAuthId
        anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
        anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
        anyTrackEvent = interactor.trackEvent
    }
    
    init(interactor: MockProfileInteractor) {
        anyCurrentUser = interactor.currentUser
        anyGetAuthId = interactor.getAuthId
        anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
        anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
        anyTrackEvent = interactor.trackEvent
    }
    
    init(interactor: ProdProfileInteractor) {
        anyCurrentUser = interactor.currentUser
        anyGetAuthId = interactor.getAuthId
        anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
        anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
        anyTrackEvent = interactor.trackEvent
    }
    
    var currentUser: AIChat.UserModel? {
        anyCurrentUser
    }
    
    func getAuthId() throws -> String {
        try anyGetAuthId()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AIChat.AvatarModel] {
        try await anyGetAvatarsForAuthor(userId)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await anyRemoveAuthorIdFromAvatar(avatarId)
    }
    
    func trackEvent(event: any AIChat.LoggableEvent) {
        anyTrackEvent(event)
    }
}
