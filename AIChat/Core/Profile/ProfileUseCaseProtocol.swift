//
//  ProfileUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.08.2025.
//

import Foundation

@MainActor
protocol ProfileUseCaseProtocol {
    var currentUser: UserModel? { get }
    
    func getAuthId() throws -> String
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    
    func trackEvent(event: any LoggableEvent)
}
