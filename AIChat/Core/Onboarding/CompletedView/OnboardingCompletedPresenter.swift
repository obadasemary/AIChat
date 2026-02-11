//
//  OnboardingCompletedPresenter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingCompletedPresenter {
    
    private let onboardingCompletedInteractor: OnboardingCompletedInteractorProtocol
    private let router: OnboardingCompletedRouterProtocol
    
    private(set) var isCompletingProfileSetup: Bool = false
    
    init(
        onboardingCompletedInteractor: OnboardingCompletedInteractorProtocol,
        router: OnboardingCompletedRouterProtocol
    ) {
        self.onboardingCompletedInteractor = onboardingCompletedInteractor
        self.router = router
    }
}

// MARK: - Action
extension OnboardingCompletedPresenter {
    
    func onFinishButtonPressed(selectedColor: Color) {
        isCompletingProfileSetup = true
        onboardingCompletedInteractor.trackEvent(event: Event.finishStart)
        Task {
            do {
                let hex = selectedColor.asHex()
                try await onboardingCompletedInteractor
                    .markOnboardingCompleteForCurrentUser(
                        profileColorHex: hex
                    )
                onboardingCompletedInteractor
                    .trackEvent(
                        event: Event.finishSuccess(
                            hex: hex
                        )
                    )
                
                isCompletingProfileSetup = false
                
                onboardingCompletedInteractor.updateAppState(showTabBarView: true)
            } catch {
                isCompletingProfileSetup = false
                router.showAlert(error: error)
                onboardingCompletedInteractor
                    .trackEvent(
                        event: Event.finishFail(
                            error: error
                        )
                    )
            }
        }
    }
}

// MARK: - Event
private extension OnboardingCompletedPresenter {
    
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
            case .finishStart: "OnboardingCompletedView_Finish_Start"
            case .finishSuccess: "OnboardingCompletedView_Finish_Success"
            case .finishFail: "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
