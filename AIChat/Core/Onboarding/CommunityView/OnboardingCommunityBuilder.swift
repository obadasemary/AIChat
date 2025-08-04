//
//  OnboardingCommunityBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI

@Observable
@MainActor
final class OnboardingCommunityBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildOnboardingCommunityView(delegate: OnboardingCommunityDelegate) -> some View {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(
                onboardingCommunityUseCase: OnboardingCommunityUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
}
