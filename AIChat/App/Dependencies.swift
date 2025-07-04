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
        case .dev:
            let pList = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: pList)!
            FirebaseApp.configure(options: options)
        case .prod:
            let pList = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: pList)!
            FirebaseApp.configure(options: options)
        }
    }
    // swiftlint:enable force_unwrapping
}

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    
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
            abTestManager = ABTestManager(
                service: MockABTestService(),
                logManager: logManager
            )
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
                service: MockABTestService(),
                logManager: logManager
            )
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
                service: MockABTestService(),
                logManager: logManager
            )
        }
        
        pushManager = PushManager(logManager: logManager)
    }
    // swiftlint:enable function_body_length
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(ABTestManager(service: MockABTestService()))
            .environment(PushManager())
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
            .environment(LogManager(services: []))
    }
}

