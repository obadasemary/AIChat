@MainActor
class DevPreview {
    
    static let shared = DevPreview()
    
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    
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