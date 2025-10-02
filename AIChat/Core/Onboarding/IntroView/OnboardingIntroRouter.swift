//
//  OnboardingIntroRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.10.2025.
//


import SwiftUI
import SUIRouting

@MainActor
protocol OnboardingIntroRouterProtocol {
//    func showOnboardingIntroView(delegate: OnboardingIntroDelegate)
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelegate)
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

@MainActor
struct OnboardingIntroRouter {
    let router: Router
    let onboardingCommunityBuilder: OnboardingCommunityBuilder
    let onboardingColorBuilder: OnboardingColorBuilder
}
    
extension OnboardingIntroRouter: OnboardingIntroRouterProtocol {
    
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelegate) {
        router.showScreen(.push) { router in
            onboardingCommunityBuilder
                .buildOnboardingCommunityView(delegate: delegate)
        }
    }
    
    func showOnboardingColorView(delegate: OnboardingColorDelegate) {
        router.showScreen(.push) { router in
            onboardingColorBuilder
                .buildOnboardingColorView(delegate: delegate)
        }
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
//extension CoreRouter: OnboardingIntroRouterProtocol {}
