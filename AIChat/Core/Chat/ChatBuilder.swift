//
//  ChatBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI
import SUIRouting

/// Builder for constructing Chat feature views with proper dependency injection.
///
/// Architectural Pattern:
/// - Follows Builder Pattern for view construction
/// - Uses DependencyContainer (service locator) for dependency resolution
/// - Creates UseCases directly, which internally resolve their own dependencies
/// - Provides nested builders to routers for child view navigation
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
                // UseCase handles its own dependency resolution from container
                // This keeps builder logic simple while maintaining testability
                chatUseCase: ChatUseCase(container: container),
                router: ChatRouter(
                    router: router,
                    // Nested builder enables router to navigate to paywall when needed
                    paywallBuilder: PaywallBuilder(container: container)
                )
            ),
            delegate: delegate
        )
    }
}
