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
    @Environment(LogManager.self) private var logManager
    
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
                onSignInWithAppleTapped()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
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
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
    }
}

// MARK: - Action
private extension CreateAccountView {
    
    func onSignInWithAppleTapped() {
        logManager.trackEvent(event: Event.appleAuthStart)
        
        Task {
            do {
                let result = try await authManager.signInWithApple()
                logManager.trackEvent(
                    event: Event.appleAuthSuccess(
                        user: result.user,
                        isNewUser: result.isNewUser
                    )
                )
                try await userManager
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager
                    .trackEvent(
                        event: Event.appleAuthLoginSuccess(
                            user: result.user,
                            isNewUser: result.isNewUser
                        )
                    )
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
    
    func onSignInWithGoogleTapped() {
        logManager.trackEvent(event: Event.googleAuthStart)
        
        Task {
            do {
                let result = try await authManager.signInWithGoogle()
                logManager.trackEvent(
                    event: Event.googleAuthSuccess(
                        user: result.user,
                        isNewUser: result.isNewUser
                    )
                )
                try await userManager
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager
                    .trackEvent(
                        event: Event.googleAuthLoginSuccess(
                            user: result.user,
                            isNewUser: result.isNewUser
                        )
                    )
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.googleAuthFail(error: error))
            }
        }
    }
}

// MARK: - Event
private extension CreateAccountView {
    
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)
        case googleAuthStart
        case googleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case googleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case googleAuthFail(error: Error)
        
        var eventName: String {
            switch self {
            case .appleAuthStart: "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess: "CreateAccountView_AppleAuth_Success"
            case .appleAuthLoginSuccess: "CreateAccountView_AppleAuth_LoginSuccess"
            case .appleAuthFail: "CreateAccountView_AppleAuth_Fail"
            case .googleAuthStart: "CreateAccountView_GoogleAuth_Start"
            case .googleAuthSuccess: "CreateAccountView_GoogleAuth_Success"
            case .googleAuthLoginSuccess: "CreateAccountView_GoogleAuth_LoginSuccess"
            case .googleAuthFail: "CreateAccountView_GoogleAuth_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser),
                    .googleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .googleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(error: let error), .googleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail, .googleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .previewEnvironment()
}
