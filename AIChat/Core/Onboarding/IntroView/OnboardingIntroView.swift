//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @State var viewModel: OnboardingIntroViewModel
    let delegate: OnboardingIntroDelegate
    
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
            
            Text("Continue")
                .callToActionButton()
                .anyButton(.press) {
                    viewModel.onContinuePress(path: delegate.path)
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
    let contaner = DevPreview.shared.container
    let onboardingIntroBuilder = OnboardingIntroBuilder(container: contaner)
    let delegate = OnboardingIntroDelegate(path: .constant([]))
    return NavigationStack {
        onboardingIntroBuilder.buildOnboardingIntroView(delegate: delegate)
            .previewEnvironment()
    }
}

#Preview("T") {
    NavigationStack {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                OnboardingIntroUseCase: OnboardingIntroUseCase(
                    container: DevPreview.shared.container
                )
            ),
            delegate: OnboardingIntroDelegate(path: .constant([]))
        )
    }
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
    
    let onboardingIntroBuilder = OnboardingIntroBuilder(container: contaner)
    let delegate = OnboardingIntroDelegate(path: .constant([]))
    
    return NavigationStack {
        onboardingIntroBuilder.buildOnboardingIntroView(delegate: delegate)
    }
    .previewEnvironment()
}
