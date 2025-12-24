//
//  OnboardingCommunityViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingCommunityPresenter {
    
    private let onboardingCommunityInteractor: OnboardingCommunityInteractorProtocol
    private let router: OnboardingCommunityRouterProtocol
    
    init(
        onboardingCommunityInteractor: OnboardingCommunityInteractorProtocol,
        router: OnboardingCommunityRouterProtocol
    ) {
        self.onboardingCommunityInteractor = onboardingCommunityInteractor
        self.router = router
    }
}

extension OnboardingCommunityPresenter {
    
    func onContinuePress() {
        router.showOnboardingColorView(delegate: OnboardingColorDelegate())
    }
}
