//
//  DevPreview.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import Foundation

@MainActor
class DevPreview {
    
    static let shared = DevPreview()
    
    var container: DIContainer {
        
        let container = DIContainer()
        container.register(AuthManager.self, authManager)
        container.register(UserManager.self, userManager)
        container.register(AIManager.self, aiManager)
        container.register(AvatarManager.self, avatarManager)
        container.register(ChatManager.self, chatManager)
        container.register(LogManager.self, logManager)
        container.register(PushManager.self, pushManager)
        container.register(ABTestManager.self, abTestManager)
        container.register(PurchaseManager.self, purchaseManager)
        
        return container
    }
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    
    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(
            service: MockAuthService(currentUser: isSignedIn ? .mock() : nil)
        )
        self.userManager = UserManager(
            services: MockUserServices(currentUser: isSignedIn ? .mock : nil)
        )
        self.aiManager = AIManager(service: MockAIServer())
        self.avatarManager = AvatarManager(remoteService: MockAvatarService())
        self.chatManager = ChatManager(service: MockChatService())
        self.logManager = LogManager(services: [])
        self.pushManager = PushManager()
        self.abTestManager = ABTestManager(service: MockABTestService())
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
    }
}
