//
//  TabBarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
            ChatsView()
                .tabItem {
                    Label(
                        "Chats",
                        systemImage: "bubble.left.and.bubble.right"
                    )
                }
            ProfileView(
                viewModel: ProfileViewModel(
                    authManager: authManager,
                    userManager: userManager,
                    avatarManager: avatarManager,
                    logManager: logManager
                )
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
