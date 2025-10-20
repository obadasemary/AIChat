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
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
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
