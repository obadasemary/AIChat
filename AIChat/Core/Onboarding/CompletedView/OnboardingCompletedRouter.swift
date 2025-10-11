//
//  OnboardingCompletedRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol OnboardingCompletedRouterProtocol {
    func showAlert(error: Error)
}

@MainActor
struct OnboardingCompletedRouter {
    let router: Router
}

extension OnboardingCompletedRouter: OnboardingCompletedRouterProtocol {
    
    func showAlert(error: any Error) {
        router
            .showAlert(
                .alert,
                title: "Error",
                subtitle: error.localizedDescription,
                buttons: nil
            )
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: OnboardingCompletedRouterProtocol {}
