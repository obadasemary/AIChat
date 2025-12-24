//
//  CreateAvatarUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI

@MainActor
protocol CreateAvatarInteractorProtocol {
    func getAuthId() throws -> String
    func generateImage(input: String) async throws -> UIImage
    func generateImage() async throws -> UIImage
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class CreateAvatarInteractor {
    
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for CreateAvatarUseCase")
        }
        guard let aiManager = container.resolve(AIManager.self) else {
            preconditionFailure("Failed to resolve AIManager for CreateAvatarUseCase")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for CreateAvatarUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for CreateAvatarUseCase")
        }
        
        self.authManager = authManager
        self.aiManager = aiManager
        self.avatarManager = avatarManager
        self.logManager = logManager
    }
}

extension CreateAvatarInteractor: CreateAvatarInteractorProtocol {
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    // swiftlint:disable force_unwrapping
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
    // swiftlint:enable force_unwrapping
}
