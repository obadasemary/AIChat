//
//  OnboardingCommunityRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol OnboardingCommunityRouterProtocol {
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

@MainActor
struct OnboardingCommunityRouter {
    let router: Router
    let onboardingColorBuilder: OnboardingColorBuilder
}

extension OnboardingCommunityRouter: OnboardingCommunityRouterProtocol {
    
    func showOnboardingColorView(delegate: OnboardingColorDelegate) {
        router.showScreen(.push) { router in
            onboardingColorBuilder
                .buildOnboardingColorView(router: router, delegate: delegate)
        }
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: OnboardingCommunityRouterProtocol {}
