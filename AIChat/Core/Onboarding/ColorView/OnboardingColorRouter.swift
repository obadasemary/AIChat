//
//  OnboardingColorRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol OnboardingColorRouterProtocol {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

@MainActor
struct OnboardingColorRouter {
    let router: Router
    let onboardingCompletedBuilder: OnboardingCompletedBuilder
}

extension OnboardingColorRouter: OnboardingColorRouterProtocol {
    
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate) {
        router.showScreen(.push) { router in
            onboardingCompletedBuilder
                .buildOnboardingCompletedView(
                    router: router,
                    delegate: delegate
                )
        }
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: OnboardingColorRouterProtocol {}
