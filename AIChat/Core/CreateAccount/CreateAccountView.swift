//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.05.2025.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.authService) private var authService
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
            .frame(height: 55)
            .anyButton(.press) {
                onSignInWithAppleTapped()
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
    
    func onSignInWithAppleTapped() {
        Task {
            do {
                let result = try await authService.signInApple()
                print("Signed in with Apple ID: \(result.user.email ?? "Unknown")")
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                print("Error signing in with Apple: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
