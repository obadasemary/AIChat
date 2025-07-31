//
//  TabBarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(DependencyContainer.self) private var container
    @Environment(ExploreBuilder.self) private var exploreBuilder
    
    var body: some View {
        TabView {
            exploreBuilder.buildExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
            ChatsView(
                viewModel: ChatsViewModel(
                    chatsUseCase: ChatsUseCase(container: container)
                )
            )
            .tabItem {
                Label(
                    "Chats",
                    systemImage: "bubble.left.and.bubble.right"
                )
            }
            ProfileView(
                viewModel: ProfileViewModel(
                    interactor: CoreInteractor(container: container)
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
