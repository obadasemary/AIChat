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
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[OnboardingPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case .onboardingIntro:
                    OnboardingIntroView(
                        viewModel: OnboardingIntroViewModel(
                            OnboardingIntroUseCase: OnboardingIntroUseCase(
                                container: container
                            )
                        ),
                        path: path
                    )
                case .onboardingCommunity:
                    OnboardingCommunityView(
                        viewModel: OnboardingCommunityViewModel(
                            onboardingCommunityUseCase: OnboardingCommunityUseCase(
                                container: container
                            )
                        ),
                        path: path
                    )
                case .onboardingColor:
                    OnboardingColorView(
                        viewModel: OnboardingColorViewModel(
                            onboardingColorUseCase: OnboardingColorUseCase(
                                container: container
                            )
                        ),
                        path: path
                    )
                case .onboardingComplete(selectedColor: let selectedColor):
                    OnboardingCompletedView(
                        viewModel: OnboardingCompletedViewModel(
                            onboardingCompletedUseCase: OnboardingCompletedUseCase(
                                container: container
                            )
                        ),
                        selectedColor: selectedColor
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
