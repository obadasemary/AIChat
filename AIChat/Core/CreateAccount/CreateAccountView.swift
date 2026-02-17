//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.05.2025.
//

import SwiftUI

struct CreateAccountView: View {

    @State var viewModel: CreateAccountViewModel
    var delegate: CreateAccountDelegate = CreateAccountDelegate()

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(delegate.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(delegate.subtitle)
                    .font(.body)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                signInButton(
                    icon: Image(systemName: "apple.logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20),
                    title: "Sign in with Apple"
                ) {
                    viewModel.onSignInWithAppleTapped(delegate: delegate)
                }

                signInButton(
                    icon: Image("GoogleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20),
                    title: "Sign in with Google"
                ) {
                    viewModel.onSignInWithGoogleTapped(delegate: delegate)
                }
            }
            .frame(maxWidth: 375)
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
        .showCustomAlert(alert: $viewModel.alert)
    }

    private func signInButton(
        icon: some View,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            icon
            Text(title)
                .font(.body)
                .fontWeight(.medium)
        }
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .anyButton(.press, action: action)
    }
}

#Preview {
    let builder = CreateAccountBuilder(container: DevPreview.shared.container)
    let delegate = CreateAccountDelegate()

    return RouterView { router in
        builder
            .buildCreateAccountView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
