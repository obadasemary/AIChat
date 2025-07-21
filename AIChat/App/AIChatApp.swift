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
                    AppView()
                }
            }
            .environment(delegate.dependencies.purchaseManager)
            .environment(delegate.dependencies.abTestManager)
            .environment(delegate.dependencies.pushManager)
            .environment(delegate.dependencies.chatManager)
            .environment(delegate.dependencies.aiManager)
            .environment(delegate.dependencies.avatarManager)
            .environment(delegate.dependencies.userManager)
            .environment(delegate.dependencies.authManager)
            .environment(delegate.dependencies.logManager)
        }
    }
}
