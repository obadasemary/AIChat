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
    private let router: WelcomeRouterProtocol
    
    private(set) var imageName: String = Constants.randomImage
    var showSignInView: Bool = false
    
    init(
        welcomeUseCase: WelcomeUseCaseProtocol,
        router: WelcomeRouterProtocol
    ) {
        self.welcomeUseCase = welcomeUseCase
        self.router = router
    }
}

// MARK: - Action
extension WelcomeViewModel {
    
    func onGetStartedPressed() {
        router.showOnboardingIntroView(delegate: OnboardingIntroDelegate())
        welcomeUseCase.trackEvent(event: Event.getStartedPressed)
    }
    
    func handleDidSignIn(isNewUser: Bool) {
        welcomeUseCase
            .trackEvent(
                event: Event.didSignIn(
                    isNewUser: isNewUser
                )
            )
        
        if isNewUser {
            
        } else {
            welcomeUseCase.updateAppState(showTabBarView: true)
        }
    }
    
    func onSignInPressed() {
        welcomeUseCase.trackEvent(event: Event.signInPressed)
        
        let delegate = CreateAccountDelegate(
            title: "Sign In",
            subtitle: "Connect to an existing account"
        ) { isNewUser in
            self.handleDidSignIn(isNewUser: isNewUser)
        }
        
        router.showCreateAccountView(delegate: delegate, onDisappear: nil)
    }
}

// MARK: - Event
private extension WelcomeViewModel {
    
    enum Event: LoggableEvent {
        case getStartedPressed
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .getStartedPressed: "WelcomeView_GetStarted_Pressed"
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
