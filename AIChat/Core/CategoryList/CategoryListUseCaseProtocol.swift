//
//  CategoryListUseCaseProtocol.swift
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
