//
//  OnboardingIntroUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation

@MainActor
protocol OnboardingIntroUseCaseProtocol {
    var onboardingCommunityTest: Bool { get }
}

@MainActor
final class OnboardingIntroUseCase {
    
    private let abTestManager: ABTestManager
    
    init(container: DependencyContainer) {
        guard let abTestManager = container.resolve(ABTestManager.self) else {
            fatalError("Required dependencies not registered in container")
        }
        self.abTestManager = abTestManager
    }
}

extension OnboardingIntroUseCase: OnboardingIntroUseCaseProtocol {
    
    var onboardingCommunityTest: Bool {
        abTestManager.activeTests.onboardingCommunityTest
    }
}
