//
//  ChatBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class ChatBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildChatView(router: Router, delegate: ChatDelegate) -> some View {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: container),
                router: ChatRouter(
                    router: router,
                    paywallBuilder: PaywallBuilder(container: container)
                )
            ),
            delegate: delegate
        )
    }
}
