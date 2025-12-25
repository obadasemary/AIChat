//
//  OnboardingIntroInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation

@MainActor
protocol OnboardingIntroInteractorProtocol {
    var onboardingCommunityTest: Bool { get }
}

@MainActor
final class OnboardingIntroInteractor {
    
    private let abTestManager: ABTestManager
    
    init(container: DependencyContainer) {
        guard let abTestManager = container.resolve(ABTestManager.self) else {
            preconditionFailure("Failed to resolve ABTestManager for OnboardingIntroInteractor")
        }
        self.abTestManager = abTestManager
    }
}

extension OnboardingIntroInteractor: OnboardingIntroInteractorProtocol {
    
    var onboardingCommunityTest: Bool {
        abTestManager.activeTests.onboardingCommunityTest
    }
}
