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
final class OnboardingIntroPresenter {
    
    private let OnboardingIntroInteractor: OnboardingIntroInteractorProtocol
    private let router: OnboardingIntroRouterProtocol
    
    var onboardingCommunityTest: Bool {
        OnboardingIntroInteractor.onboardingCommunityTest
    }
    
    init(
        OnboardingIntroInteractor: OnboardingIntroInteractorProtocol,
        router: OnboardingIntroRouterProtocol
    ) {
        self.OnboardingIntroInteractor = OnboardingIntroInteractor
        self.router = router
    }
}

extension OnboardingIntroPresenter {
    
    func onContinuePress() {
        if onboardingCommunityTest {
            router.showOnboardingCommunityView(delegate: OnboardingCommunityDelegate())
        } else {
            router.showOnboardingColorView(delegate: OnboardingColorDelegate())
        }
    }
}
