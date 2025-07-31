//
//  ChatBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class ChatBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildChatView(delegate: ChatDelegate) -> some View {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: container)
            ),
            delegate: delegate
        )
    }
}
