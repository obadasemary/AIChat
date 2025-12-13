//
//  Dependencies.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

enum BuildConfiguration {
    case mock(isSignedIn: Bool)
    case dev
    case prod
    
    // swiftlint:disable force_unwrapping
    func configureFirebase() {
        switch self {
        case .mock:
            break
        case .dev, .prod:
            if let pList = ConfigurationManager.shared.getFirebaseConfigPath(for: self) {
                let options = FirebaseOptions(contentsOfFile: pList)!
                FirebaseApp.configure(options: options)
            } else {
                print("❌ Firebase configuration not found for \(self)")
            }
        }
    }
    // swiftlint:enable force_unwrapping
}

@MainActor
struct Dependencies {
    
    let container: DependencyContainer
    
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let newsFeedManager: NewsFeedManager
    let networkMonitor: NetworkMonitor
    let bookmarkManager: BookmarkManager
    let appState: AppState
    
    // swiftlint:disable function_body_length
    init(configuration: BuildConfiguration) {
        switch configuration {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(
                services: [
                    ConsoleService(printParameters: false)
                ]
            )
            authManager = AuthManager(
                service: MockAuthService(
                    currentUser: isSignedIn ? .mock() : nil
                ),
                logManager: logManager
            )
            userManager = UserManager(
                services: MockUserServices(
                    currentUser: isSignedIn ? .mock : nil
                ),
                logManager: logManager
            )
            aiManager = AIManager(service: MockAIServer())
            avatarManager = AvatarManager(
                remoteService: MockAvatarService(),
                localStorage: MockLocalAvatarServicePersistence()
            )
            chatManager = ChatManager(service: MockChatService())
            
            let isInOnboardingCommunityTest = ProcessInfo
                .processInfo
                .arguments
                .contains("ONBOARDING_COMMUNITY_TEST")
            
            let abTestService = MockABTestService(
                onboardingCommunityTest: isInOnboardingCommunityTest
            )
            
            abTestManager = ABTestManager(
                service: abTestService,
                logManager: logManager
            )
            purchaseManager = PurchaseManager(
                service: MockPurchaseService(),
                logManager: logManager
            )
            networkMonitor = NetworkMonitor()
            newsFeedManager = NewsFeedManager(
                remoteService: MockRemoteNewsFeedService(),
                localStorage: MockLocalNewsFeedService(),
                networkMonitor: networkMonitor,
                logManager: logManager
            )
            bookmarkManager = BookmarkManager()
            appState = AppState(showTabBar: isSignedIn)
        case .dev:
            logManager = LogManager(
                services: [
                    ConsoleService(),
                    FirebaseAnalyticsService(),
                    MixpanelService(token: Keys.mixpanelToken),
                    FirebaseCrashlyticsService()
                ]
            )
            authManager = AuthManager(
                service: FirebaseAuthService(),
                logManager: logManager
            )
            userManager = UserManager(
                services: ProductionUserServices(),
                logManager: logManager
            )
            aiManager = AIManager(service: OpenAIServer())
            avatarManager = AvatarManager(
                remoteService: FirebaseAvatarService(
                    firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
                ),
                localStorage: SwiftDataLocalAvatarServicePersistence()
            )
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(
                service: LocalABTestService(),
                logManager: logManager
            )
            purchaseManager = PurchaseManager(
                service: StoreKitPurchaseService(),
                logManager: logManager
            )
            networkMonitor = NetworkMonitor()
            newsFeedManager = NewsFeedManager(
                remoteService: RemoteNewsFeedService(),
                localStorage: FileManagerNewsFeedService(),
                networkMonitor: networkMonitor,
                logManager: logManager
            )
            bookmarkManager = BookmarkManager()
            appState = AppState()
        case .prod:
            logManager = LogManager(
                services: [
                    FirebaseAnalyticsService(),
                    MixpanelService(token: Keys.mixpanelToken),
                    FirebaseCrashlyticsService()
                ]
            )
            authManager = AuthManager(
                service: FirebaseAuthService(),
                logManager: logManager
            )
            userManager = UserManager(
                services: ProductionUserServices(),
                logManager: logManager
            )
            aiManager = AIManager(service: OpenAIServer())
            avatarManager = AvatarManager(
                remoteService: FirebaseAvatarService(
                    firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
                ),
                localStorage: SwiftDataLocalAvatarServicePersistence()
            )
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(
                service: FirebaseABTestService(),
                logManager: logManager
            )
            purchaseManager = PurchaseManager(
                service: StoreKitPurchaseService(),
                logManager: logManager
            )
            networkMonitor = NetworkMonitor()
            newsFeedManager = NewsFeedManager(
                remoteService: RemoteNewsFeedService(),
                localStorage: FileManagerNewsFeedService(),
                networkMonitor: networkMonitor,
                logManager: logManager
            )
            bookmarkManager = BookmarkManager()
            appState = AppState()
        }

        pushManager = PushManager(logManager: logManager)
        
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
        container.register(AppState.self, appState)

        self.container = container
    }
    // swiftlint:enable function_body_length
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(LogManager(services: []))
            .environment(AppBuilder(container: DevPreview.shared.container))
            .environment(TabBarBuilder(container: DevPreview.shared.container))
            .environment(WelcomeBuilder(container: DevPreview.shared.container))
            .environment(
                OnboardingIntroBuilder(container: DevPreview.shared.container)
            )
            .environment(
                OnboardingCommunityBuilder(container: DevPreview.shared.container)
            )
            .environment(
                OnboardingColorBuilder(container: DevPreview.shared.container)
            )
            .environment(
                OnboardingCompletedBuilder(container: DevPreview.shared.container)
            )
            .environment(
                ExploreBuilder(
                    container: DevPreview.shared.container
//                    ,
//                    devSettingsBuilder: DevSettingsBuilder(container: DevPreview.shared.container),
//                    createAccountBuilder: CreateAccountBuilder(container: DevPreview.shared.container)
                )
            )
            .environment(
                CreateAccountBuilder(container: DevPreview.shared.container)
            )
            .environment(
                DevSettingsBuilder(container: DevPreview.shared.container)
            )
            .environment(
                CategoryListBuilder(container: DevPreview.shared.container)
            )
            .environment(
                ChatsBuilder(container: DevPreview.shared.container)
            )
            .environment(
                ChatRowCellBuilder(container: DevPreview.shared.container)
            )
            .environment(
                ChatBuilder(container: DevPreview.shared.container)
            )
            .environment(
                PaywallBuilder(container: DevPreview.shared.container)
            )
            .environment(
                ProfileBuilder(container: DevPreview.shared.container)
            )
            .environment(
                SettingsBuilder(container: DevPreview.shared.container)
            )
            .environment(
                CreateAvatarBuilder(container: DevPreview.shared.container)
            )
            .environment(
                NewsFeedBuilder(container: DevPreview.shared.container)
            )
    }
}
