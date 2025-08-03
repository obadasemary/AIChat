//
//  ChatsBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI

@Observable
@MainActor
final class ChatsBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildChatsView() -> some View {
        ChatsView(
            viewModel: ChatsViewModel(
                chatsUseCase: ChatsUseCase(container: container)
            )
        )
    }
}
