//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @Environment(ABTestManager.self) private var abTestManager
    
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
                if abTestManager.activeTests.onboardingCommunityTest {
                    OnboardingCommunityView()
                } else {
                    OnboardingColorView()
                }
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
}

#Preview("Original") {
    NavigationStack {
        OnboardingIntroView()
    }
    .previewEnvironment()
}

#Preview("Onb Comm Test") {
    NavigationStack {
        OnboardingIntroView()
    }
    .environment(
        ABTestManager(
            service: MockABTestService(
                onboardingCommunityTest: true
            )
        )
    )
    .previewEnvironment()
}
