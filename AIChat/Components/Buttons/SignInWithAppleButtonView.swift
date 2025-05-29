//
//  SignInWithAppleButtonView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.05.2025.
//

import SwiftUI
import AuthenticationServices

public struct SignInWithAppleButtonView: View {
    public let type: ASAuthorizationAppleIDButton.ButtonType
    public let style: ASAuthorizationAppleIDButton.Style
    public let cornerRadius: CGFloat
    
    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        style: ASAuthorizationAppleIDButton.Style = .black,
        cornerRadius: CGFloat = 10
    ) {
        self.type = type
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.001)
            
            SignInWithAppleButtonViewRepresentable(type: type, style: style, cornerRadius: cornerRadius)
                .disabled(true)
        }
    }
}

private struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let cornerRadius: CGFloat
    
    func makeUIView(context: Context) -> some UIView {
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.cornerRadius = cornerRadius
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() {
        
    }
}

#Preview("SignInWithAppleButtonView") {
    ZStack {
        VStack(spacing: 4) {
            SignInWithAppleButtonView(
                type: .signUp,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 50)
        }
        .padding(40)
    }
}
