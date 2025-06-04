//
//  NavigationPathOption.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.06.2025.
//

import SwiftUI

enum NavigationPathOption: Hashable {
    case chat(avatarId: String)
    case character(category: CharacterOption, imageName: String)
}

extension View {
    
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        self
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .chat(avatarId: let avatarId):
                    ChatView(avatarId: avatarId)
                case .character(category: let category, imageName: let imageName):
                    CategoryListView(
                        path: path,
                        category: category,
                        imageName: imageName
                    )
                }
            }
    }
}
