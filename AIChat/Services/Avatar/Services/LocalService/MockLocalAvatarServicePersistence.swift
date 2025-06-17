//
//  MockLocalAvatarServicePersistence.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.06.2025.
//

import Foundation

struct MockLocalAvatarServicePersistence {}

extension MockLocalAvatarServicePersistence: LocalAvatarServicePersistenceProtocol {
    func addRecentAvatar(avatar: AvatarModel) throws {}

    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
