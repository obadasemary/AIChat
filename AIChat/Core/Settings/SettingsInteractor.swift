//
//  SettingsInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol SettingsInteractorProtocol {
    var auth: UserAuthInfo? { get }
    func signOut() throws
    func deleteAccount() async throws
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class SettingsInteractor {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for SettingsInteractor")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for SettingsInteractor")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for SettingsInteractor")
        }
        guard let chatManager = container.resolve(ChatManager.self) else {
            preconditionFailure("Failed to resolve ChatManager for SettingsInteractor")
        }
        guard let appState = container.resolve(AppState.self) else {
            preconditionFailure("Failed to resolve AppState for SettingsInteractor")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for SettingsInteractor")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.avatarManager = avatarManager
        self.chatManager = chatManager
        self.appState = appState
        self.logManager = logManager
    }
}

extension SettingsInteractor: SettingsInteractorProtocol {
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func signOut() throws {
        try authManager.signOut()
        userManager.signOut()
    }
    
    func deleteAccount() async throws {
        let userId = try authManager.getAuthId()
        
        //                async let deleteAuth: () = authManager.deleteAccount()
        //                async let deleteUser: () = userManager.deleteCurrentUser()
        //                async let deleteAvatar: () = avatarManager
        //                    .removeAuthorIdFromAllUserAvatars(userId: userId)
        //                async let deleteChats: () = chatManager.deleteAllChatsForUser(
        //                    userId: userId
        //                )
        //
        //                let (_, _, _, _) = await (
        //                    try deleteAuth,
        //                    try deleteUser,
        //                    try deleteAvatar,
        //                    try deleteChats
        //                )
        
        try await chatManager.deleteAllChatsForUser(userId: userId)
        
        try await avatarManager
            .removeAuthorIdFromAllUserAvatars(userId: userId)
        
        try await userManager.deleteCurrentUser()
        
        try await authManager.deleteAccount()
        
        // FIXME: implement
        // try await purchaseManager.logOut()
        logManager.deleteUserProfile()
    }
    
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
