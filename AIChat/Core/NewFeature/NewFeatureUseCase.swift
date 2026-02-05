//
//  NewFeatureUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import Foundation
import SwiftfulUtilities

@MainActor
protocol NewFeatureUseCaseProtocol {
    func trackEvent(event: any LoggableEvent)
    // Add use case methods here
}

@MainActor
final class NewFeatureUseCase {

    private let logManager: LogManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
        // Resolve additional dependencies here
    }
}

extension NewFeatureUseCase: NewFeatureUseCaseProtocol {

    func trackEvent(event: any LoggableEvent) {
        logManager?.trackEvent(event: event)
    }

    // Implement use case methods here
}
