//
//  CreateAvatarUseCase.swift
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

@MainActor
final class CreateAvatarUseCase {
    
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

extension CreateAvatarUseCase: CreateAvatarUseCaseProtocol {
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    func generateImage() async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: URL(string: Constants.randomImage)!)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return image
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
