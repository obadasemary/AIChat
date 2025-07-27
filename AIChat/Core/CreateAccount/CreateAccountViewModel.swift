//
//  CreateAccountViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@Observable
@MainActor
final class CreateAccountViewModel {
    
    private let createAccountUseCase: CreateAccountUseCaseProtocol
    
    init(createAccountUseCase: CreateAccountUseCaseProtocol) {
        self.createAccountUseCase = createAccountUseCase
    }
}

// MARK: - Action
extension CreateAccountViewModel {
    
    func onSignInWithAppleTapped(
        onDidSignInSuccessfully: @escaping (_ isNewUser: Bool) -> Void
    ) {
        createAccountUseCase.trackEvent(event: Event.appleAuthStart)
        
        Task {
            do {
                let result = try await createAccountUseCase.signInWithApple()
                createAccountUseCase.trackEvent(
                    event: Event.appleAuthSuccess(
                        user: result.user,
                        isNewUser: result.isNewUser
                    )
                )
                try await createAccountUseCase
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
                createAccountUseCase
                    .trackEvent(
                        event: Event.appleAuthLoginSuccess(
                            user: result.user,
                            isNewUser: result.isNewUser
                        )
                    )
                
                onDidSignInSuccessfully(result.isNewUser)
            } catch {
                createAccountUseCase.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
    
    func onSignInWithGoogleTapped(
        onDidSignInSuccessfully: @escaping (_ isNewUser: Bool) -> Void
    ) {
        createAccountUseCase.trackEvent(event: Event.googleAuthStart)
        
        Task {
            do {
                let result = try await createAccountUseCase.signInWithGoogle()
                createAccountUseCase.trackEvent(
                    event: Event.googleAuthSuccess(
                        user: result.user,
                        isNewUser: result.isNewUser
                    )
                )
                try await createAccountUseCase
                    .logIn(auth: result.user, isNewUser: result.isNewUser)
                createAccountUseCase
                    .trackEvent(
                        event: Event.googleAuthLoginSuccess(
                            user: result.user,
                            isNewUser: result.isNewUser
                        )
                    )
                
                onDidSignInSuccessfully(result.isNewUser)
            } catch {
                createAccountUseCase.trackEvent(event: Event.googleAuthFail(error: error))
            }
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
