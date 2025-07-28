//
//  OnboardingColorViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingColorViewModel {
    
    private let onboardingColorUseCase: OnboardingColorUseCaseProtocol
    
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
    
    var path: [OnboardingPathOption] = []
    
    init(onboardingColorUseCase: OnboardingColorUseCaseProtocol) {
        self.onboardingColorUseCase = onboardingColorUseCase
    }
}

extension OnboardingColorViewModel {
    
    func onColorPressed(color: Color) {
        selectedColor = color
        onboardingColorUseCase
            .trackEvent(event: Event.onboardingColorSelected)
    }
    
    func onContinuePress(path: Binding<[OnboardingPathOption]>) {
        guard let selectedColor else { return }
        path.wrappedValue.append(.onboardingComplete(selectedColor: selectedColor))
    }
}

// MARK: - Event
private extension OnboardingColorViewModel {
    
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
