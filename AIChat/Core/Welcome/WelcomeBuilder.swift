//
//  WelcomeBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class WelcomeBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildWelcomeView() -> some View {
        WelcomeView(
            viewModel: WelcomeViewModel(
                welcomeUseCase: WelcomeUseCase(container: container)
            )
        )
    }
}
