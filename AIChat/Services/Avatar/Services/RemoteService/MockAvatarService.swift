//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import SwiftUI

struct MockAvatarService {
    
    let avatars: [AvatarModel]
    let delay: Double
    let showError: Bool
    let showErrorForRemoveAuthorIdFromAvatar: Bool
    
    init(
        avatars: [AvatarModel] = AvatarModel.mocks,
        delay: Double = 0.0,
        showError: Bool = false,
        showErrorForRemoveAuthorIdFromAvatar: Bool = false
    ) {
        self.avatars = avatars
        self.delay = delay
        self.showError = showError
        self.showErrorForRemoveAuthorIdFromAvatar = showErrorForRemoveAuthorIdFromAvatar
    }
}

extension MockAvatarService: RemoteAvatarServiceProtocol {
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        guard let avatar = avatars.first(where: { $0.id == id }) else {
            throw URLError(.noPermissionsToReadFile)
        }
        return avatar
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {}
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        if showErrorForRemoveAuthorIdFromAvatar {
            throw URLError(.unknown)
        }
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {}
}

private extension MockAvatarService {
    func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
