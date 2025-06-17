//
//  LocalAvatarServicePersistenceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.06.2025.
//

import SwiftUI

protocol LocalAvatarServicePersistenceProtocol: Sendable {
    @MainActor func addRecentAvatar(avatar: AvatarModel) throws
    @MainActor func getRecentAvatars() throws -> [AvatarModel]
}
