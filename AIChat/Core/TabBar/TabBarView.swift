//
//  TabBarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        TabView {
            ExploreView(viewModel: ExploreViewModel(container: container))
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
            ChatsView()
            ExploreView(
                viewModel: ExploreViewModel(
                    interactor: CoreInteractor(container: container)
                )
            )
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }
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
