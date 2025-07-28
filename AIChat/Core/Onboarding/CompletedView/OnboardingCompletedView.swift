//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var appState
    @State var viewModel: OnboardingCompletedViewModel
    
    var selectedColor: Color = .accent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup completed!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
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
                                selectedColor: selectedColor
                            ) {
                                appState.updateViewState(showTabBarView: true)
                            }
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
    OnboardingCompletedView(
        viewModel: OnboardingCompletedViewModel(
            onboardingCompletedUseCase: OnboardingCompletedUseCase(
                container: DevPreview
                    .shared.container)
        ),
        selectedColor: .orange
    )
    .previewEnvironment()
}
