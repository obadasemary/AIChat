//
//  MockLocalAvatarServicePersistence.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.06.2025.
//

import Foundation

struct MockLocalAvatarServicePersistence {
    
    let avatars: [AvatarModel]
    let delay: Double
    let showError: Bool
    
    init(
        avatars: [AvatarModel] = AvatarModel.mocks,
        delay: Double = 0.0,
        showError: Bool = false
    ) {
        self.avatars = avatars
        self.delay = delay
        self.showError = showError
    }
}

extension MockLocalAvatarServicePersistence: LocalAvatarServicePersistenceProtocol {
    
    func addRecentAvatar(avatar: AvatarModel) throws {}

    func getRecentAvatars() throws -> [AvatarModel] {
        avatars
    }
}

private extension MockLocalAvatarServicePersistence {
    func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
