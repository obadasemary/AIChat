//
//  ProfileUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.08.2025.
//

import Foundation

@MainActor
protocol ProfileUseCaseProtocol {
    var currentUser: UserModel? { get }
    
    func getAuthId() throws -> String
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
    func removeAuthorIdFromAvatar(avatarId: String) async throws
    func updateProfileColor(profileColorHex: String) async throws
    
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class ProfileUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for ProfileUseCase")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for ProfileUseCase")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for ProfileUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for ProfileUseCase")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.avatarManager = avatarManager
        self.logManager = logManager
    }
}

extension ProfileUseCase: ProfileUseCaseProtocol {
    
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
    
    func updateProfileColor(profileColorHex: String) async throws {
        try await userManager.updateProfileColorForCurrentUser(profileColorHex: profileColorHex)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
