//
//  AppView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct AppView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State var appState: AppState = .init()
    
    var body: some View {
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
        .task {
            await checkUserStatus()
        }
        .onAppear {
            logManager
                .identify(
                    userId: "abc123",
                    name: "mock user",
                    email: "ai@example.com"
                )
            logManager
                .addUserProperty(
                    dict: UserModel.mock.eventParameters,
                    isHighPriority: false
                )
            
            let event = AnyLoggableEvent(
                eventName: "My New Event",
                parameters: UserModel.mock.eventParameters,
                type: .analytic
            )
            
            logManager
                .trackEvent(event: event)
            logManager
                .trackEvent(eventName: "Another Event")
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // User is authenticated
            print("User already authenticated: \(user.uid)")
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                print("Failed to log in to auth for existing user: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                print("Sign in anonymous success: \(result.user.uid)")
                try await userManager
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                print("Failed to sign in to annonimously and login: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

public enum Event: LoggableEvent {
    case alpha, beta, gamma, delta, epsilon, zeta
    
    var eventName: String {
        switch self {
        case .alpha: "alpha"
        case .beta: "beta"
        case .gamma: "gamma"
        case .delta: "delta"
        case .epsilon: "epsilon"
        case .zeta: "zeta"
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .alpha, .beta:
            [
                "aaa": true,
                "bbb": 123
            ]
        default:
            nil
        }
    }

    var type: LogType {
        switch self {
        case .alpha:
                .info
        case .beta:
                .analytic
        case .gamma:
                .warning
        case .delta:
                .severe
        case .epsilon:
                .warning
        case .zeta:
                .info
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

