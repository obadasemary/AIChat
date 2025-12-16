//
//  OnboardingColorUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol OnboardingColorUseCaseProtocol {
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class OnboardingColorUseCase {
    
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let logManager = container.resolve(LogManager.self) else {
            fatalError("Required dependencies not registered in container")
        }
        self.logManager = logManager
    }
}

extension OnboardingColorUseCase: OnboardingColorUseCaseProtocol {
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
