//
//  WelcomeView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState

    @State var viewModel: WelcomeViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: viewModel.imageName)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 24)
                
                ctaButtons
                    .padding(16)
                
                policyLinks
            }
        }
        .screenAppearAnalytics(name: "WelcomeView")
        .sheet(isPresented: $viewModel.showSignInView) {
            CreateAccountView(
                viewModel: CreateAccountViewModel(
                    createAccountUseCase: CreateAccountUseCase(
                        container: container
                    )
                ),
                title: "Sign In",
                subtitle: "Connect to an existing account",
                onDidSignIn: { isNewUser in
                    viewModel
                        .handleDidSignIn(isNewUser: isNewUser) {
                            appState.updateViewState(showTabBarView: true)
                        }
                }
            )
            .presentationDetents([.medium])
        }
    }
}

// MARK: - SectionViews
private extension WelcomeView {
    
    var titleSection: some View {
        VStack(spacing: 8) {
            Text("AI Chat 🤙")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text("Twitter: @Obadasemary")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
    
    var ctaButtons: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingIntroView(
                    viewModel: OnboardingIntroViewModel(
                        OnboardingIntroUseCase: OnboardingIntroUseCase(
                            container: container
                        )
                    )
                )
            } label: {
                Text("Get Started")
                    .callToActionButton()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .accessibilityIdentifier("StartButton")
            .frame(maxWidth: 500)
            
            Text("Already have an account? Sign in")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    viewModel.onSignInPressed()
                }
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    var policyLinks: some View {
        // swiftlint:disable force_unwrapping
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceURL)!) {
                Text("Terms of Service")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
        }
        // swiftlint:enable force_unwrapping
    }
}

#Preview {
    WelcomeView(
        viewModel: WelcomeViewModel(
            welcomeUseCase: WelcomeUseCase(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}
