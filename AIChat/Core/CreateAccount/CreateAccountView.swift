//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.05.2025.
//

import SwiftUI
import GoogleSignInSwift

struct CreateAccountView: View {
    
    @State var viewModel: CreateAccountViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var title: String = "Create Account"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(subtitle)
                    .font(.body)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(maxWidth: 375)
            .frame(height: 55)
            .anyButton(.press) {
                viewModel.onSignInWithAppleTapped { isNewUser in
                    onDidSignIn?(isNewUser)
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            GoogleSignInButton(
                viewModel: GoogleSignInButtonViewModel(
                    scheme: .dark,
                    style: .wide,
                    state: .normal
                )
            ) {
                viewModel.onSignInWithGoogleTapped { isNewUser in
                    onDidSignIn?(isNewUser)
                    dismiss()
                }
            }
            .frame(maxWidth: 375)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
    }
}

#Preview {
    CreateAccountView(
        viewModel: CreateAccountViewModel(
            createAccountUseCase: CreateAccountUseCase(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}
