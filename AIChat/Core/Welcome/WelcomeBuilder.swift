//
//  WelcomeBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class WelcomeBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildWelcomeView(router: Router) -> some View {
        WelcomeView(
            presenter: WelcomePresenter(
                welcomeInteractor: WelcomeInteractor(container: container),
                router: WelcomeRouter(
                    router: router,
                    onboardingIntroBuilder: OnboardingIntroBuilder(
                        container: container
                    ),
                    createAccountBuilder: CreateAccountBuilder(
                        container: container
                    )
                )
            )
        )
    }
}


