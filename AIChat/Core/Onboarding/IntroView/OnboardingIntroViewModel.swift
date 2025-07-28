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
    
    var onboardingCommunityTest: Bool {
        OnboardingIntroUseCase.onboardingCommunityTest
    }
    
    var path: [OnboardingPathOption] = []
    
    init(OnboardingIntroUseCase: OnboardingIntroUseCaseProtocol) {
        self.OnboardingIntroUseCase = OnboardingIntroUseCase
    }
}

extension OnboardingIntroViewModel {
    
    func onContinuePress(path: Binding<[OnboardingPathOption]>) {
        if onboardingCommunityTest {
            path.wrappedValue.append(.onboardingCommunity)
        } else {
            path.wrappedValue.append(.onboardingColor)
        }
    }
}
