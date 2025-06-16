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
}

private extension AvatarManager {}
