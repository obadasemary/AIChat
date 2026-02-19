//
//  TabBarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct TabBarView: View {

    @Environment(ExploreBuilder.self) private var exploreBuilder
    @Environment(ChatsBuilder.self) private var chatsBuilder
    @Environment(ProfileBuilder.self) private var profileBuilder
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        
        TabView(selection: $appState.selectedTab) {
            RouterView { router in
                exploreBuilder.buildExploreView(router: router)
            }
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }
            .tag(AppTab.explore)
            
            RouterView { router in
                chatsBuilder.buildChatsView(router: router)
            }
            .tabItem {
                Label(
                    "Chats",
                    systemImage: "bubble.left.and.bubble.right"
                )
            }
            .tag(AppTab.chats)
            
            RouterView { router in
                profileBuilder.buildProfileView(router: router)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(AppTab.profile)
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
