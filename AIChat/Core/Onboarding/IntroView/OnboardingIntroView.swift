//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @State var presenter: OnboardingIntroPresenter
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
                    presenter.onContinuePress()
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
    let delegate = OnboardingIntroDelegate()
    
    return RouterView { router in
        onboardingIntroBuilder
            .buildOnboardingIntroView(router: router, delegate: delegate)
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
    
    let onboardingIntroBuilder = OnboardingIntroBuilder(container: contaner)
    let delegate = OnboardingIntroDelegate()
    
    return RouterView { router in
        onboardingIntroBuilder
            .buildOnboardingIntroView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
