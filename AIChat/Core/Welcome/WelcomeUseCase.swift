//
//  WelcomeUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class WelcomeUseCase {
    
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
    }
}

extension WelcomeUseCase: WelcomeUseCaseProtocol {
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
