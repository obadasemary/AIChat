//
//  AIChatApp.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI
import SwiftfulUtilities

struct AIChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if Utilities.isUITesting {
                    AppViewForUITesting()
                } else {
                    AppView(
                        viewModel: AppViewModel(
                            appViewUseCase: AppViewUseCase(
                                container: delegate
                                    .dependencies
                                    .container
                            )
                        )
                    )
                }
            }
            .environment(
                CoreBuilder(container: delegate.dependencies.container)
            )
            .environment(
                AppBuilder(container: delegate.dependencies.container)
            )
            .environment(
                TabBarBuilder(container: delegate.dependencies.container)
            )
            .environment(
                WelcomeBuilder(container: delegate.dependencies.container)
            )
            .environment(
                ExploreBuilder(container: delegate.dependencies.container)
            )
            .environment(
                CreateAccountBuilder(container: delegate.dependencies.container)
            )
            .environment(
                DevSettingsBuilder(container: delegate.dependencies.container)
            )
            .environment(
                CategoryListBuilder(container: delegate.dependencies.container)
            )
            .environment(
                ChatBuilder(container: delegate.dependencies.container)
            )
            .environment(
                PaywallBuilder(container: delegate.dependencies.container)
            )
            .environment(
                CreateAvatarBuilder(container: delegate.dependencies.container)
            )
            .environment(delegate.dependencies.container)
            .environment(delegate.dependencies.logManager)
        }
    }
}
