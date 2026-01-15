//
//  OnboardingCommunityBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class OnboardingCommunityBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildOnboardingCommunityView(
        router: Router,
        delegate: OnboardingCommunityDelegate
    ) -> some View {
        OnboardingCommunityView(
            presenter: OnboardingCommunityPresenter(
                onboardingCommunityInteractor: OnboardingCommunityInteractor(
                    container: container
                ),
                router: OnboardingCommunityRouter(
                    router: router,
                    onboardingColorBuilder: OnboardingColorBuilder(
                        container: container
                    )
                )
            ),
            delegate: delegate
        )
    }
}
