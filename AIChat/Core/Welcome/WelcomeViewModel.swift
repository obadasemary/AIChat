//
//  WelcomeViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@Observable
@MainActor
class WelcomeViewModel {
    
    private let welcomeUseCase: WelcomeUseCaseProtocol
    
    private(set) var imageName: String = Constants.randomImage
    var showSignInView: Bool = false
    
    init(welcomeUseCase: WelcomeUseCaseProtocol) {
        self.welcomeUseCase = welcomeUseCase
    }
}

// MARK: - Action
extension WelcomeViewModel {
    
    func handleDidSignIn(isNewUser: Bool, onShowTabBarView: () -> Void) {
        welcomeUseCase
            .trackEvent(
                event: Event.didSignIn(
                    isNewUser: isNewUser
                )
            )
        
        if isNewUser {
            
        } else {
            onShowTabBarView()
        }
    }
    
    func onSignInPressed() {
        showSignInView = true
        welcomeUseCase.trackEvent(event: Event.signInPressed)
    }
}

// MARK: - Event
private extension WelcomeViewModel {
    
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn: "WelcomeView_DidSignIn"
            case .signInPressed: "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return [
                    "is_new_user": isNewUser
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
