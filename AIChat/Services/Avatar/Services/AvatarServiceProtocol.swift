//
//  AvatarServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import SwiftUI

protocol AvatarServiceProtocol: Sendable {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}
