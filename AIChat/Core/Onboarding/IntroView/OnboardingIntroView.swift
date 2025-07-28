//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingIntroViewModel
    
    var body: some View {
        VStack {
            Group {
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat with them! \n\nHave ")
                +
                Text("real conversation ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with AI generated responses.")
            }
            .baselineOffset(6)
            .minimumScaleFactor(0.5)
            .frame(maxHeight: .infinity)
            .padding(24)
            
            NavigationLink {
                if viewModel.onboardingCommunityTest {
                    OnboardingCommunityView(
                        viewModel: OnboardingCommunityViewModel(
                            onboardingCommunityUseCase: OnboardingCommunityUseCase(
                                container: container
                            )
                        )
                    )
                } else {
                    OnboardingColorView(
                        viewModel: OnboardingColorViewModel(
                            onboardingColorUseCase: OnboardingColorUseCase(
                                container: container
                            )
                        )
                    )
                }
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
            .accessibilityIdentifier("ContinueButton")
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
}

#Preview("Original") {
    NavigationStack {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                OnboardingIntroUseCase: OnboardingIntroUseCase(
                    container: DevPreview.shared.container
                )
            )
        )
    }
    .previewEnvironment()
}

#Preview("Onb Comm Test") {
    let contaner = DevPreview.shared.container
    
    contaner.register(ABTestManager.self) {
        ABTestManager(
            service: MockABTestService(
                onboardingCommunityTest: true
            )
        )
    }
    
    return NavigationStack {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                OnboardingIntroUseCase: OnboardingIntroUseCase(
                    container: contaner
                )
            )
        )
    }
    .previewEnvironment()
}
