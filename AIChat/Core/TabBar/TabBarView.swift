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
    @Environment(NewsFeedBuilder.self) private var newsFeedBuilder
    @Environment(ProfileBuilder.self) private var profileBuilder

    var body: some View {
        TabView {
            RouterView { router in
                exploreBuilder.buildExploreView(router: router)
            }
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }
            RouterView { router in
                chatsBuilder.buildChatsView(router: router)
            }
            .tabItem {
                Label(
                    "Chats",
                    systemImage: "bubble.left.and.bubble.right"
                )
            }
            RouterView { router in
                newsFeedBuilder.buildNewsFeedView()
            }
            .tabItem {
                Label("News", systemImage: "newspaper")
            }
            RouterView { router in
                profileBuilder.buildProfileView(router: router)
            }
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
