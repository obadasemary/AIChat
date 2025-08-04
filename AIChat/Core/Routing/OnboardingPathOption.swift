//
//  OnboardingPathOption.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import SwiftUI

enum OnboardingPathOption: Hashable {
    case onboardingIntro
    case onboardingCommunity
    case onboardingColor
    case onboardingComplete(selectedColor: Color)
}

struct NavigationDestinationForOnboardingModuleViewModifier: ViewModifier {
    
    @Environment(OnboardingIntroBuilder.self) private var onboardingIntroBuilder
    @Environment(OnboardingCommunityBuilder.self) private var onboardingCommunityBuilder
    @Environment(OnboardingColorBuilder.self) private var onboardingColorBuilder
    @Environment(OnboardingCompletedBuilder.self) private var onboardingCompletedBuilder
    let path: Binding<[OnboardingPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case .onboardingIntro:
                    onboardingIntroBuilder
                        .buildOnboardingIntroView(
                            delegate: OnboardingIntroDelegate(path: path)
                        )
                case .onboardingCommunity:
                    onboardingCommunityBuilder
                        .buildOnboardingCommunityView(
                            delegate: OnboardingCommunityDelegate(path: path)
                        )
                case .onboardingColor:
                    onboardingColorBuilder
                        .buildOnboardingColorView(
                            delegate: OnboardingColorDelegate(path: path)
                        )
                case .onboardingComplete(selectedColor: let selectedColor):
                    onboardingCompletedBuilder
                        .buildOnboardingCompletedView(
                            delegate: OnboardingCompletedDelegate(
                                selectedColor: selectedColor
                            )
                        )
                }
            }
    }
}

extension View {
    
    func navigationDestinationForOnboardingModule(path: Binding<[OnboardingPathOption]>) -> some View {
        modifier(NavigationDestinationForOnboardingModuleViewModifier(path: path))
    }
}
