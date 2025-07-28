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
    
    var path: [OnboardingPathOption] = []
    
    init(onboardingCommunityUseCase: OnboardingCommunityUseCaseProtocol) {
        self.onboardingCommunityUseCase = onboardingCommunityUseCase
    }
}

extension OnboardingCommunityViewModel {
    
    func onContinuePress(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.onboardingColor)
    }
}
