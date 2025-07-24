//
//  ProdProfileInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.07.2025.
//

import Foundation

@MainActor
struct ProdProfileInteractor {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

extension ProdProfileInteractor: ProfileInteractor {
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuthor(userId: userId)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}

extension CoreInteractor: ProfileInteractor {}
