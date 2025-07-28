//
//  OnboardingColorUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class OnboardingColorUseCase {
    
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
    }
}

extension OnboardingColorUseCase: OnboardingColorUseCaseProtocol {
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
