//
//  OnboardingCommunityViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@Observable
@MainActor
class OnboardingCommunityViewModel {
    
    private let onboardingCommunityUseCase: OnboardingCommunityUseCaseProtocol
    
    init(onboardingCommunityUseCase: OnboardingCommunityUseCaseProtocol) {
        self.onboardingCommunityUseCase = onboardingCommunityUseCase
    }
}
