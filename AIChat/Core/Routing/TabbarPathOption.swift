//
//  TabbarPathOption.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.06.2025.
//

import SwiftUI

enum TabbarPathOption: Hashable {
    case chat(avatarId: String, chat: ChatModel?)
    case character(category: CharacterOption, imageName: String)
}

struct NavigationDestinationForTabbarModuleViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[TabbarPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabbarPathOption.self) { newValue in
                switch newValue {
                case .chat(avatarId: let avatarId, chat: let chat):
                    ChatView(
                        viewModel: ChatViewModel(
                            chatUseCase: ChatUseCase(container: container)
                        ),
                        avatarId: avatarId,
                        chat: chat
                    )
                case .character(category: let category, imageName: let imageName):
                    CategoryListView(
                        viewModel: CategoryListViewModel(
                            categoryListUseCase: CategoryListUseCase(
                                container: container
                            )
                        ),
                        delegate: CategoryListDelegate(
                            category: category,
                            imageName: imageName,
                            path: path
                        )
                    )
                }
            }
    }
}

extension View {
    
    func navigationDestinationForTabbarModule(path: Binding<[TabbarPathOption]>) -> some View {
        modifier(NavigationDestinationForTabbarModuleViewModifier(path: path))
    }
}
