//
//  OnboardingCommunityView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.07.2025.
//

import SwiftUI

struct OnboardingCommunityView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCommunityViewModel
    @Binding var path: [OnboardingPathOption]
    
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
            
            Text("Continue")
                .callToActionButton()
                .anyButton(.press) {
                    viewModel.onContinuePress(path: $path)
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
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(
                onboardingCommunityUseCase: OnboardingCommunityUseCase(
                    container: DevPreview.shared.container
                )
            ),
            path: .constant([])
        )
    }
    .previewEnvironment()
}
