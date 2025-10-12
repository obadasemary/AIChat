//
//  OnboardingIntroBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class OnboardingIntroBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildOnboardingIntroView(
        router: Router,
        delegate: OnboardingIntroDelegate
    ) -> some View {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                OnboardingIntroUseCase: OnboardingIntroUseCase(
                    container: container
                ),
                router: OnboardingIntroRouter(
                    router: router,
                    onboardingCommunityBuilder: OnboardingCommunityBuilder(
                        container: container
                    ),
                    onboardingColorBuilder: OnboardingColorBuilder(
                        container: container
                    )
                )
            ),
            delegate: delegate
        )
    }
}
