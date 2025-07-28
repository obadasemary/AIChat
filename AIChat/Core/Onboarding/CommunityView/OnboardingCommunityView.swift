//
//  OnboardingCommunityView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.07.2025.
//

import SwiftUI

struct OnboardingCommunityView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                ImageLoaderView()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                
                Group {
                    Text("Join our community with over ")
                    +
                    Text("1000+ ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                    +
                    Text("custom avatars. \nAsk them questions or have a casual conversation with them.")
                }
                .baselineOffset(6)
                .minimumScaleFactor(0.5)
                .padding(24)
            }
            .frame(maxHeight: .infinity)
            
            NavigationLink {
                OnboardingColorView(
                    viewModel: OnboardingColorViewModel(
                        onboardingColorUseCase: OnboardingColorUseCase(
                            container: container
                        )
                    )
                )
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
            .accessibilityIdentifier("OnboardingCommunityContinueButton")
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCommunityView")
    }
}

#Preview {
    NavigationStack {
        OnboardingCommunityView()
    }
    .environment(AppState())
    .previewEnvironment()
}
