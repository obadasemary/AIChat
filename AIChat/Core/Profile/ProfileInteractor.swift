//
//  ProfileInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.07.2025.
//

import Foundation

@MainActor
protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    
    func getAuthId() throws -> String
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    func updateProfileColor(profileColorHex: String) async throws
    
    func trackEvent(event: any LoggableEvent)
}

extension CoreInteractor: ProfileInteractor {}
