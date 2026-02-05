//
//  AppView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct AppView: View {
    
    @Environment(AppBuilder.self) private var appBuilder
    @Environment(TabBarBuilder.self) private var tabBarBuilder
    @Environment(WelcomeBuilder.self) private var welcomeBuilder
    @State var viewModel: AppViewModel
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await viewModel.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            )
        ) {
            AppViewBuilder(
                showTabBar: viewModel.showTabBar,
                tabBarView: {
                    tabBarBuilder.buildTabBarView()
                },
                onboardingView: {
                    return RouterView { router in
                        welcomeBuilder.buildWelcomeView(router: router)
                    }
                }
            )
            .preferredColorScheme(colorSchemeManager.currentColorScheme)
            .screenAppearAnalytics(name: Self.screenName)
            .task {
                await viewModel.checkUserStatus()
            }
            .task {
                try? await Task.sleep(for: .seconds(2))
                await viewModel.showATTPromptIfNeeded()
            }
            .onChange(of: viewModel.showTabBar) { _, showTabBar in
                if !showTabBar {
                    Task {
                        await viewModel.checkUserStatus()
                    }
                }
            }
        }
    }
}

#Preview("AppView - TabBar") {
    let container = DevPreview.shared.container
    
    container.register(AppState.self) {
        AppState(showTabBar: true)
    }
    
    let builder = CoreBuilder(container: container)
    
    return builder.appView()
        .previewEnvironment()
}

#Preview("AppView - Onboarding") {
    let container = DevPreview.shared.container
    
    container.register(UserManager.self) {
        UserManager(services: MockUserServices(currentUser: nil))
    }
    
    container.register(AuthManager.self) {
        AuthManager(service: MockAuthService(currentUser: nil))
    }
    
    container.register(AppState.self) {
        AppState(showTabBar: false)
    }
    
    let builder = AppBuilder(container: container)
    
    return builder.buildAppView()
        .previewEnvironment()
}

