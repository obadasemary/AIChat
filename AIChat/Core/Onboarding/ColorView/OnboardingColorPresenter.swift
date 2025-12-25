//
//  OnboardingColorPresenter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingColorPresenter {
    
    private let onboardingColorInteractor: OnboardingColorInteractorProtocol
    private let router: OnboardingColorRouterProtocol
    
    private(set) var selectedColor: Color?
    let profileColors: [Color] = [
        .red,
        .green,
        .orange,
        .blue,
        .mint,
        .yellow,
        .purple,
        .pink,
        .cyan,
        .teal,
        .indigo,
        .brown
    ]
    
    init(
        onboardingColorInteractor: OnboardingColorInteractorProtocol,
        router: OnboardingColorRouterProtocol
    ) {
        self.onboardingColorInteractor = onboardingColorInteractor
        self.router = router
    }
}

extension OnboardingColorPresenter {
    
    func onColorPressed(color: Color) {
        selectedColor = color
        onboardingColorInteractor
            .trackEvent(event: Event.onboardingColorSelected)
    }
    
    func onContinuePress() {
        guard let selectedColor else { return }
        let delegate = OnboardingCompletedDelegate(selectedColor: selectedColor)
        router.showOnboardingCompletedView(delegate: delegate)
    }
}

// MARK: - Event
private extension OnboardingColorPresenter {
    
    enum Event: LoggableEvent {
        case onboardingColorSelected
        
        var eventName: String {
            switch self {
            case .onboardingColorSelected: "onboarding_color_selected"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
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
