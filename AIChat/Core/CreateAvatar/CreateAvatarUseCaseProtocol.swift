//
//  CreateAvatarUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI

@MainActor
protocol CreateAvatarUseCaseProtocol {
    func getAuthId() throws -> String
    func generateImage(input: String) async throws -> UIImage
    func generateImage() async throws -> UIImage
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    func trackEvent(event: any LoggableEvent)
}
