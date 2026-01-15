//
//  OnboardingColorBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class OnboardingColorBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildOnboardingColorView(
        router: Router,
        delegate: OnboardingColorDelegate
    ) -> some View {
        OnboardingColorView(
            presenter: OnboardingColorPresenter(
                onboardingColorInteractor: OnboardingColorInteractor(
                    container: container
                ),
                router: OnboardingColorRouter(
                    router: router,
                    onboardingCompletedBuilder: OnboardingCompletedBuilder(
                        container: container
                    )
                )
            ),
            delegate: delegate
        )
    }
}
