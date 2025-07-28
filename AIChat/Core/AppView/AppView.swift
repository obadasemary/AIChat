//
//  AppView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct AppView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: AppViewModel
    
    @State var appState: AppState = .init()
    
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
                showTabBar: appState.showTabBar,
                tabBarView: {
                    TabBarView()
                },
                onboardingView: {
                    WelcomeView(
                        viewModel: WelcomeViewModel(
                            welcomeUseCase: WelcomeUseCase(container: container)
                        )
                    )
                }
            )
            .environment(appState)
            .screenAppearAnalytics(name: Self.screenName)
            .task {
                await viewModel.checkUserStatus()
            }
            .task {
                try? await Task.sleep(for: .seconds(2))
                await viewModel.showATTPromptIfNeeded()
            }
            .onChange(of: appState.showTabBar) { _, showTabBar in
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
    AppView(
        viewModel: AppViewModel(
            appViewUseCase: AppViewUseCase(container: DevPreview.shared.container)
        ),
        appState: AppState(showTabBar: true)
    )
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
    
    return AppView(
        viewModel: AppViewModel(
            appViewUseCase: AppViewUseCase(
                container: container
            )
        ),
        appState: AppState(showTabBar: false)
    )
    .previewEnvironment(isSignedIn: false)
}

