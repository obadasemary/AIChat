//
//  OnboardingCompletedViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingCompletedViewModel {
    
    private let onboardingCompletedUseCase: OnboardingCompletedUseCaseProtocol
    
    private(set) var isCompletingProfileSetup: Bool = false
    
    var showAlert: AnyAppAlert?
    
    var path: [OnboardingPathOption] = []
    
    init(onboardingCompletedUseCase: OnboardingCompletedUseCaseProtocol) {
        self.onboardingCompletedUseCase = onboardingCompletedUseCase
    }
}

// MARK: - Action
extension OnboardingCompletedViewModel {
    
    func onFinishButtonPressed(selectedColor: Color, onShowTabBarView: @escaping () -> Void) {
        isCompletingProfileSetup = true
        onboardingCompletedUseCase.trackEvent(event: Event.finishStart)
        Task {
            do {
                let hex = selectedColor.asHex()
                try await onboardingCompletedUseCase
                    .markOnboardingCompleteForCurrentUser(
                        profileColorHex: hex
                    )
                onboardingCompletedUseCase
                    .trackEvent(
                        event: Event.finishSuccess(
                            hex: hex
                        )
                    )
                
                isCompletingProfileSetup = false
                onShowTabBarView()
            } catch {
                showAlert = AnyAppAlert(error: error)
                onboardingCompletedUseCase
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
private extension OnboardingCompletedViewModel {
    
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
