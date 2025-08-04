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
            let rootView = Group {
                if Utilities.isUITesting {
                    AppViewForUITesting()
                } else {
                    delegate.appBuilder.buildAppView()
                }
            }

            rootView
                .environment(delegate.appBuilder)
                .environment(delegate.welcomeBuilder)
                .environment(delegate.onboardingIntroBuilder)
                .environment(delegate.onboardingCommunityBuilder)
                .environment(delegate.onboardingColorBuilder)
                .environment(delegate.onboardingCompletedBuilder)
                .environment(delegate.tabBarBuilder)
                .environment(delegate.exploreBuilder)
                .environment(delegate.categoryListBuilder)
                .environment(delegate.devSettingsBuilder)
                .environment(delegate.createAccountBuilder)
                .environment(delegate.chatsBuilder)
                .environment(delegate.chatRowCellBuilder)
                .environment(delegate.chatBuilder)
                .environment(delegate.paywallBuilder)
                .environment(delegate.profileBuilder)
                .environment(delegate.settingsBuilder)
                .environment(delegate.createAvatarBuilder)
                .environment(delegate.dependencies.logManager)
        }
    }
}
