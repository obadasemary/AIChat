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
    
    var body: some View {
        TabView {
            exploreBuilder.buildExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
            chatsBuilder.buildChatsView()
                .tabItem {
                    Label(
                        "Chats",
                        systemImage: "bubble.left.and.bubble.right"
                    )
                }
            profileBuilder.buildProfileView()
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
