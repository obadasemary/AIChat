//
//  ChatsBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class ChatsBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildChatsView(router: Router) -> some View {
        ChatsView(
            presenter: ChatsPresenter(
                chatsInteractor: ChatsInteractor(container: container),
                router: ChatsRouter(
                    router: router,
                    chatBuilder: ChatBuilder(container: container)
                )
            )
        )
    }
}
