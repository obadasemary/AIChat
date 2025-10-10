//
//  OnboardingCommunityViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingCommunityViewModel {
    
    private let onboardingCommunityUseCase: OnboardingCommunityUseCaseProtocol
    private let router: OnboardingCommunityRouterProtocol
    
    init(
        onboardingCommunityUseCase: OnboardingCommunityUseCaseProtocol,
        router: OnboardingCommunityRouterProtocol
    ) {
        self.onboardingCommunityUseCase = onboardingCommunityUseCase
        self.router = router
    }
}

extension OnboardingCommunityViewModel {
    
    func onContinuePress() {
        router.showOnboardingColorView(delegate: OnboardingColorDelegate())
    }
}
