//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import SwiftUI

struct MockAvatarService {}

extension MockAvatarService: AvatarServiceProtocol {
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {}
}
