//
//  AppView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

// tabBar - signed in
// onboarding - signed out

struct AppView: View {
    
    @AppStorage("showTabBarView") var showTabBar: Bool = false
    
    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabBarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
    }
}

#Preview("AppView - TabBar") {
    AppView(showTabBar: true)
}

#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}

