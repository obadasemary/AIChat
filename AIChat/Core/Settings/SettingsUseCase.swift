//
//  SettingsUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class SettingsUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.appState = container.resolve(AppState.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

extension SettingsUseCase: SettingsUseCaseProtocol {
    
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
