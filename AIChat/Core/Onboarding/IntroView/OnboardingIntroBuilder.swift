//
//  OnboardingIntroBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI

@Observable
@MainActor
final class OnboardingIntroBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildOnboardingIntroView(delegate: OnboardingIntroDelegate) -> some View {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                OnboardingIntroUseCase: OnboardingIntroUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
}
