//
//  Dependencies.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation
import FirebaseFirestore

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    
    init() {
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        aiManager = AIManager(service: OpenAIServer())
        avatarManager = AvatarManager(
            service: FirebaseAvatarService(
                firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
            )
        )
    }
}
