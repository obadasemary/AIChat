//
//  AIChatApp.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

@main
struct AIChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
        }
    }
}
