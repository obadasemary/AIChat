//
//  OnboardingIntroViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class OnboardingIntroViewModel {
    
    private let OnboardingIntroUseCase: OnboardingIntroUseCaseProtocol
    private let router: OnboardingIntroRouterProtocol
    
    var onboardingCommunityTest: Bool {
        OnboardingIntroUseCase.onboardingCommunityTest
    }
    
//    var path: [OnboardingPathOption] = []
    
    init(
        OnboardingIntroUseCase: OnboardingIntroUseCaseProtocol,
        router: OnboardingIntroRouterProtocol
    ) {
        self.OnboardingIntroUseCase = OnboardingIntroUseCase
        self.router = router
    }
}

extension OnboardingIntroViewModel {
    
    func onContinuePress(path: Binding<[OnboardingPathOption]>) {
        if onboardingCommunityTest {
            router.showOnboardingCommunityView(delegate: OnboardingCommunityDelegate())
        } else {
            router.showOnboardingColorView(delegate: OnboardingColorDelegate())
        }
    }
}
