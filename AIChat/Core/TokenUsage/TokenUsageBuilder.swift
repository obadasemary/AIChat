//
//  TokenUsageBuilder.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class TokenUsageBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildTokenUsageView(router: Router) -> some View {
        TokenUsageView(
            viewModel: TokenUsageViewModel(
                useCase: TokenUsageUseCase(container: container),
                router: TokenUsageRouter(router: router)
            )
        )
    }
}
