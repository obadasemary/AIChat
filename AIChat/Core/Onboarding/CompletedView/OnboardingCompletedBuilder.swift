//
//  OnboardingCompletedBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 04.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class OnboardingCompletedBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildOnboardingCompletedView(
        router: Router,
        delegate: OnboardingCompletedDelegate
    ) -> some View {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(
                onboardingCompletedUseCase: OnboardingCompletedUseCase(
                    container: container
                ),
                router: OnboardingCompletedRouter(router: router)
            ),
            delegate: delegate
        )
    }
}
