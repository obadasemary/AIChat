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
    
    var container: DependencyContainer {

        let container = DependencyContainer()
        container.register(AuthManager.self, authManager)
        container.register(UserManager.self, userManager)
        container.register(AIManager.self, aiManager)
        container.register(AvatarManager.self, avatarManager)
        container.register(ChatManager.self, chatManager)
        container.register(LogManager.self, logManager)
        container.register(PushManager.self, pushManager)
        container.register(ABTestManager.self, abTestManager)
        container.register(PurchaseManager.self, purchaseManager)
        container.register(NewsFeedManager.self, newsFeedManager)
        container.register(NetworkMonitor.self, networkMonitor)
        container.register(BookmarkManager.self, bookmarkManager)
        container.register(AppState.self, AppState())

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
    private let newsFeedManager: NewsFeedManager
    private let networkMonitor: NetworkMonitor
    private let bookmarkManager: BookmarkManager
    private let appState: AppState
    
    init(isSignedIn: Bool = true) {
        self.logManager = LogManager(services: [])
        self.authManager = AuthManager(
            service: MockAuthService(currentUser: isSignedIn ? .mock() : nil),
            logManager: logManager
        )
        self.userManager = UserManager(
            services: MockUserServices(currentUser: isSignedIn ? .mock : nil),
            logManager: logManager
        )
        self.aiManager = AIManager(service: MockAIServer())
        self.avatarManager = AvatarManager(remoteService: MockAvatarService())
        self.chatManager = ChatManager(service: MockChatService())
        self.pushManager = PushManager(logManager: logManager)
        self.abTestManager = ABTestManager(
            service: MockABTestService(),
            logManager: logManager
        )
        self.purchaseManager = PurchaseManager(
            service: MockPurchaseService(),
            logManager: logManager
        )
        self.networkMonitor = NetworkMonitor()
        self.newsFeedManager = NewsFeedManager(
            remoteService: MockRemoteNewsFeedService(),
            localStorage: MockLocalNewsFeedService(),
            networkMonitor: networkMonitor,
            logManager: logManager
        )
        self.bookmarkManager = BookmarkManager()
        self.appState = AppState()
    }
}
