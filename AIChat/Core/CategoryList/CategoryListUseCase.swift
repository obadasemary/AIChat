//
//  CategoryListUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol CategoryListUseCaseProtocol {
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class CategoryListUseCase {
    
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for CategoryListUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for CategoryListUseCase")
        }
        self.avatarManager = avatarManager
        self.logManager = logManager
    }
}

extension CategoryListUseCase: CategoryListUseCaseProtocol {
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForCategory(category: category)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
