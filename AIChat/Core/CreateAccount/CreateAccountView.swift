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
    @Environment(\.colorScheme) private var colorScheme

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

            VStack(spacing: 12) {
                // Apple Sign In button with Apple-style design
                appleSignInButton {
                    viewModel.onSignInWithAppleTapped(delegate: delegate)
                }

                // Google Sign In button with Apple-style design
                googleSignInButton {
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
    
    private func appleSignInButton(action: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "apple.logo")
                .font(.system(size: 17, weight: .semibold))
            Text("Sign in with Apple")
                .font(.system(size: 17, weight: .semibold))
        }
        .foregroundStyle(colorScheme == .dark ? .black : .white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(colorScheme == .dark ? .white : .black)
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .anyButton(.press, action: action)
    }

    private func googleSignInButton(action: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image("GoogleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text("Sign in with Google")
                .font(.system(size: 17, weight: .semibold))
        }
        .foregroundStyle(colorScheme == .dark ? .black : .white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(colorScheme == .dark ? .white : .black)
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .anyButton(.press, action: action)
    }
}

#Preview("Light Mode") {
    let builder = CreateAccountBuilder(container: DevPreview.shared.container)
    let delegate = CreateAccountDelegate()

    return RouterView { router in
        builder
            .buildCreateAccountView(router: router, delegate: delegate)
    }
    .previewEnvironment()
    .preferredColorScheme(.light)
}
#Preview("Dark Mode") {
    let builder = CreateAccountBuilder(container: DevPreview.shared.container)
    let delegate = CreateAccountDelegate()

    return RouterView { router in
        builder
            .buildCreateAccountView(router: router, delegate: delegate)
    }
    .previewEnvironment()
    .preferredColorScheme(.dark)
}

