//
//  Dependencies.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import SwiftUI
import FirebaseFirestore

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    
    init() {
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        aiManager = AIManager(service: OpenAIServer())
        avatarManager = AvatarManager(
            remoteService: FirebaseAvatarService(
                firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
            ),
            localStorage: SwiftDataLocalAvatarServicePersistence()
        )
        chatManager = ChatManager(service: FirebaseChatService())
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(ChatManager(service: MockChatService()))
            .environment(AIManager(service: MockAIServer()))
            .environment(AvatarManager(remoteService: MockAvatarService()))
            .environment(
                UserManager(
                    services: MockUserServices(currentUser: isSignedIn ? .mock : nil)
                )
            )
            .environment(
                AuthManager(
                    service: MockAuthService(currentUser: isSignedIn ? .mock() : nil)
                )
            )
            .environment(AppState())
    }
}

