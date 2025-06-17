//
//  AvatarManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import SwiftUI

@MainActor
@Observable
final class AvatarManager {
    
    private let remoteService: RemoteAvatarServiceProtocol
    private let localStorage: LocalAvatarServicePersistenceProtocol
    
    init(
        remoteService: RemoteAvatarServiceProtocol,
        localStorage: LocalAvatarServicePersistenceProtocol = MockLocalAvatarServicePersistence()
    ) {
        self.remoteService = remoteService
        self.localStorage = localStorage
    }
}

extension AvatarManager: AvatarManagerProtocol {
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try localStorage.addRecentAvatar(avatar: avatar)
        try await remoteService.incrementAvatarClickCount(avatarId: avatar.id)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try localStorage.getRecentAvatars()
    }

    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await remoteService.createAvatar(avatar: avatar, image: image)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await remoteService.getAvatar(id: id)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await remoteService.getFeaturedAvatars()
    }

    func getPopularAvatars() async throws -> [AvatarModel] {
        try await remoteService.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remoteService.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await remoteService.getAvatarsForAuthor(userId: userId)
    }
}

private extension AvatarManager {}
