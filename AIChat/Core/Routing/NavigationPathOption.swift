//
//  NavigationPathOption.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.06.2025.
//

import SwiftUI

enum NavigationPathOption: Hashable {
    case chat(avatarId: String, chat: ChatModel?)
    case character(category: CharacterOption, imageName: String)
}

struct NavigationDestinationForCoreModuleViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavigationPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .chat(avatarId: let avatarId, chat: let chat):
                    ChatView(avatarId: avatarId, chat: chat)
                case .character(category: let category, imageName: let imageName):
                    CategoryListView(
                        viewModel: CategoryListViewModel(container: container),
                        category: category,
                        imageName: imageName,
                        path: path
                    )
                }
            }
    }
}

extension View {
    
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavigationDestinationForCoreModuleViewModifier(path: path))
    }
}
