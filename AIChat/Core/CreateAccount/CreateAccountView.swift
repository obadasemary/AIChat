//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.05.2025.
//

import SwiftUI
import GoogleSignInSwift

struct CreateAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    var title: String = "Create Account"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.body)
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
                onSignInWithAppleTapped()
            }
            
            GoogleSignInButton(
                viewModel: GoogleSignInButtonViewModel(
                    scheme: .dark,
                    style: .wide,
                    state: .normal
                )
            ) {
                onSignInWithGoogleTapped()
            }
            .frame(maxWidth: 375)
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
    
    func onSignInWithAppleTapped() {
        Task {
            do {
                let result = try await authManager.signInWithApple()
                print("Signed in with Apple ID: \(result.user.email ?? "Unknown")")
                try await userManager
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
                print("Did log in user: \(result.user)")
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                print("Error signing in with Apple: \(error.localizedDescription)")
            }
        }
    }
    
    func onSignInWithGoogleTapped() {
        Task {
            do {
                let result = try await authManager.signInWithGoogle()
                print("Signed in with Google ID: \(result.user.email ?? "Unknown")")
                try await userManager
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
                print("Did log in user: \(result.user)")
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                print("Error signing in with Google: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
