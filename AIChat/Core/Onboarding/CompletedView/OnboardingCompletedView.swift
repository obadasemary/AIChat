//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    
    @State private var isCompletingProfileSetup: Bool = false
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
                    isLoading: isCompletingProfileSetup,
                    title: "Finish",
                    action: onFinishButtonPressed
                )
            }
        )
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        Task {
            //        try await saveUserProfile(color: selectedColor)
            try await Task.sleep(for: .seconds(3))
            isCompletingProfileSetup = false
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
}
