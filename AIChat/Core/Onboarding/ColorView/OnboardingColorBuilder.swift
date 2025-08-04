//
//  OnboardingColorBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI

@Observable
@MainActor
final class OnboardingColorBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildOnboardingColorView(delegate: OnboardingColorDelegate) -> some View {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(
                onboardingColorUseCase: OnboardingColorUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
}
