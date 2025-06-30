//
//  AppView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State var appState: AppState = .init()
    
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            )
        ) {
            AppViewBuilder(
                showTabBar: appState.showTabBar,
                tabBarView: {
                    TabBarView()
                },
                onboardingView: {
                    WelcomeView()
                }
            )
            .environment(appState)
            .screenAppearAnalytics(name: Self.screenName)
            .task {
                await checkUserStatus()
            }
            .task {
                try? await Task.sleep(for: .seconds(2))
                await showATTPromptIfNeeded()
            }
            .onChange(of: appState.showTabBar) { _, showTabBar in
                if !showTabBar {
                    Task {
                        await checkUserStatus()
                    }
                }
            }
        }
    }
}

// MARK: - Action
private extension AppView {
    
    func checkUserStatus() async {
        if let user = authManager.auth {
            logManager.trackEvent(event: Event.existingAuthStart)
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager
                    .trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            logManager.trackEvent(event: Event.anonymousAuthStart)
            do {
                let result = try await authManager.signInAnonymously()
                logManager.trackEvent(event: Event.anonymousAuthSuccess)
                try await userManager
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                logManager
                    .trackEvent(event: Event.anonymousAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
    
    func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper
            .requestTrackingAuthorization()
        
        logManager
            .trackEvent(
                event: Event.attStatus(
                    dict: status.eventParameters
                )
            )
        #endif
    }
}

// MARK: - Event
private extension AppView {
    
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonymousAuthStart
        case anonymousAuthSuccess
        case anonymousAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart: "AppView_ExistingAuth_Start"
            case .existingAuthFail: "AppView_ExistingAuth_Fail"
            case .anonymousAuthStart: "AppView_AnonymousAuth_Start"
            case .anonymousAuthSuccess: "AppView_AnonymousAuth_Success"
            case .anonymousAuthFail: "AppView_AnonymousAuth_Fail"
            case .attStatus: "AppView_ATT_Status"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .existingAuthFail(error: let error),
                    .anonymousAuthFail(error: let error):
                error.eventParameters
            case .attStatus(dict: let dict):
                dict
            default:
                nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonymousAuthFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview("AppView - TabBar") {
    AppView(appState: AppState(showTabBar: true))
        .previewEnvironment()
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .previewEnvironment(isSignedIn: false)
}

