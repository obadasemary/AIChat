//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @State var viewModel: OnboardingCompletedViewModel
    let delegate: OnboardingCompletedDelegate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup completed!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(delegate.selectedColor)
            
            Text("we've set up for profile and you're ready to start chatting")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(
            edge: .bottom,
            alignment: .center,
            spacing: 16,
            content: {
                AsyncCallToActionButton(
                    isLoading: viewModel.isCompletingProfileSetup,
                    title: "Finish",
                    action: {
                        viewModel
                            .onFinishButtonPressed(
                                selectedColor: delegate.selectedColor
                            )
                    }
                )
                .accessibilityIdentifier("FinishButton")
            }
        )
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $viewModel.showAlert)
    }
}

#Preview {
    let contaner = DevPreview.shared.container
    let onboardingCompletedBuilder = OnboardingCompletedBuilder(
        container: contaner
    )
    let delegate = OnboardingCompletedDelegate(selectedColor: .orange)
    
    return RouterView { router in
        onboardingCompletedBuilder
            .buildOnboardingCompletedView(
                router: router,
                delegate: delegate
            )
    }
    .previewEnvironment()
}
