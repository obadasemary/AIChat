//
//  OnboardingColorUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol OnboardingColorUseCaseProtocol {
    func trackEvent(event: any LoggableEvent)
}
