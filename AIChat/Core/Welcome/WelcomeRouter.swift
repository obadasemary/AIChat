//
//  WelcomeRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol WelcomeRouterProtocol {
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
}

@MainActor
struct WelcomeRouter {
    let router: Router
    let onboardingIntroBuilder: OnboardingIntroBuilder
    let createAccountBuilder: CreateAccountBuilder
}

extension WelcomeRouter: WelcomeRouterProtocol {
    
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate) {
        router.showScreen(.push) { router in
            onboardingIntroBuilder
                .buildOnboardingIntroView(router: router, delegate: delegate)
        }
    }
    
    func showCreateAccountView(
        delegate: CreateAccountDelegate,
        onDisappear: (() -> Void)?
    ) {
        router.showScreen(.sheet) { router in
            createAccountBuilder
                .buildCreateAccountView(router: router, delegate: delegate)
                .presentationDetents([.medium])
                .onDisappear {
                    onDisappear?()
                }
        }
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: WelcomeRouterProtocol {}
