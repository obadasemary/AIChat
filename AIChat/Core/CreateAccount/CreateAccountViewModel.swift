//
//  CreateAccountViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation
import AuthenticationServices

@Observable
@MainActor
final class CreateAccountViewModel {
    
    private let createAccountUseCase: CreateAccountUseCaseProtocol
    private let router: CreateAccountRouterProtocol
    
    var alert: AnyAppAlert?
    
    init(
        createAccountUseCase: CreateAccountUseCaseProtocol,
        router: CreateAccountRouterProtocol
    ) {
        self.createAccountUseCase = createAccountUseCase
        self.router = router
    }
}

// MARK: - Action
extension CreateAccountViewModel {
    
    func handleAppleSignInResult(
        _ result: Result<ASAuthorization, Error>,
        delegate: CreateAccountDelegate
    ) async {
        createAccountUseCase.trackEvent(event: Event.appleAuthStart)
        
        switch result {
        case .success:
            // The SignInWithAppleButton handles the authorization request,
            // but we still need to process it through our existing auth flow
            do {
                let authResult = try await self.createAccountUseCase.signInWithApple()
                self.createAccountUseCase.trackEvent(
                    event: Event.appleAuthSuccess(
                        user: authResult.user,
                        isNewUser: authResult.isNewUser
                    )
                )
                try await self.createAccountUseCase
                    .logIn(auth: authResult.user, isNewUser: authResult.isNewUser)
                self.createAccountUseCase
                    .trackEvent(
                        event: Event.appleAuthLoginSuccess(
                            user: authResult.user,
                            isNewUser: authResult.isNewUser
                        )
                    )
                
                delegate.onDidSignIn?(authResult.isNewUser)
                self.router.dismissScreen()
            } catch {
                self.createAccountUseCase.trackEvent(event: Event.appleAuthFail(error: error))
                self.handleAuthError(error)
            }
            
        case .failure(let error):
            self.createAccountUseCase.trackEvent(event: Event.appleAuthFail(error: error))
            self.handleAuthError(error)
        }
    }
    
    // TODO: FIXME let's remove this later
//    func onSignInWithAppleTapped(
//        delegate: CreateAccountDelegate
//    ) {
//        createAccountUseCase.trackEvent(event: Event.appleAuthStart)
//        
//        Task { [weak self] in
//            guard let self else { return }
//            do {
//                let result = try await self.createAccountUseCase.signInWithApple()
//                self.createAccountUseCase.trackEvent(
//                    event: Event.appleAuthSuccess(
//                        user: result.user,
//                        isNewUser: result.isNewUser
//                    )
//                )
//                try await self.createAccountUseCase
//                    .logIn(auth: result.user, isNewUser: result.isNewUser)
//                self.createAccountUseCase
//                    .trackEvent(
//                        event: Event.appleAuthLoginSuccess(
//                            user: result.user,
//                            isNewUser: result.isNewUser
//                        )
//                    )
//                
//                delegate.onDidSignIn?(result.isNewUser)
//                self.router.dismissScreen()
//            } catch {
//                self.createAccountUseCase.trackEvent(event: Event.appleAuthFail(error: error))
//                self.handleAuthError(error)
//            }
//        }
//    }
    
    func onSignInWithGoogleTapped(
        delegate: CreateAccountDelegate
    ) {
        createAccountUseCase.trackEvent(event: Event.googleAuthStart)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.createAccountUseCase.signInWithGoogle()
                self.createAccountUseCase.trackEvent(
                    event: Event.googleAuthSuccess(
                        user: result.user,
                        isNewUser: result.isNewUser
                    )
                )
                try await self.createAccountUseCase
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
                self.createAccountUseCase
                    .trackEvent(
                        event: Event.googleAuthLoginSuccess(
                            user: result.user,
                            isNewUser: result.isNewUser
                        )
                    )
                
                delegate.onDidSignIn?(result.isNewUser)
                self.router.dismissScreen()
            } catch {
                self.createAccountUseCase.trackEvent(event: Event.googleAuthFail(error: error))
                self.handleAuthError(error)
            }
        }
    }
    
    private func handleAuthError(_ error: Error) {
        if let authError = error as? FirebaseAuthError,
           case .accountExistsWithDifferentProvider = authError {
            self.alert = AnyAppAlert(
                title: "Account Already Exists",
                subtitle: "An account with this email already exists. Please sign in with your original sign-in method first. After signing in, you can link additional sign-in methods from your profile settings."
            )
        } else {
            self.alert = AnyAppAlert(error: error)
        }
    }
}

// MARK: - Event
private extension CreateAccountViewModel {
    
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
