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
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(maxWidth: 375)
            .frame(height: 55)
            .anyButton(.press) {
                viewModel.onSignInWithAppleTapped(delegate: delegate)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            GoogleSignInButton(
                viewModel: GoogleSignInButtonViewModel(
                    scheme: .dark,
                    style: .wide,
                    state: .normal
                )
            ) {
                viewModel.onSignInWithGoogleTapped(delegate: delegate)
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
