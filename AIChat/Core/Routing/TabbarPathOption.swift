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
    
    @Environment(CategoryListBuilder.self) private var categoryListBuilder
    @Environment(ChatBuilder.self) private var chatBuilder
    let path: Binding<[TabbarPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabbarPathOption.self) { newValue in
                switch newValue {
                case .chat(avatarId: let avatarId, chat: let chat):
                    chatBuilder
                        .buildChatView(
                            delegate: ChatDelegate(
                                avatarId: avatarId,
                                chat: chat
                            )
                        )
                case .character(category: let category, imageName: let imageName):
                    categoryListBuilder
                        .buildCategoryListView(
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
