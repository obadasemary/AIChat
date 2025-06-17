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
    
    private let service: AvatarServiceProtocol
    
    init(service: AvatarServiceProtocol) {
        self.service = service
    }
}

extension AvatarManager: AvatarManagerProtocol {

    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await service.getAvatar(id: id)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await service.getFeaturedAvatars()
    }

    func getPopularAvatars() async throws -> [AvatarModel] {
        try await service.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await service.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await service.getAvatarsForAuthor(userId: userId)
    }
}

private extension AvatarManager {}
