//
//  OnboardingIntroViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation

@Observable
@MainActor
class OnboardingIntroViewModel {
    
    private let OnboardingIntroUseCase: OnboardingIntroUseCaseProtocol
    
    var onboardingCommunityTest: Bool {
        OnboardingIntroUseCase.onboardingCommunityTest
    }
    
    init(OnboardingIntroUseCase: OnboardingIntroUseCaseProtocol) {
        self.OnboardingIntroUseCase = OnboardingIntroUseCase
    }
}
