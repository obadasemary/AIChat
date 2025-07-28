//
//  OnboardingIntroUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation

@MainActor
final class OnboardingIntroUseCase {
    
    private let abTestManager: ABTestManager
    
    init(container: DependencyContainer) {
        self.abTestManager = container.resolve(ABTestManager.self)!
    }
}

extension OnboardingIntroUseCase: OnboardingIntroUseCaseProtocol {
    
    var onboardingCommunityTest: Bool {
        abTestManager.activeTests.onboardingCommunityTest
    }
}
