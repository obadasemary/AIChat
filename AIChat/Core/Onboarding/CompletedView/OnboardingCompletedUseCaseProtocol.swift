//
//  OnboardingCompletedUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation

@MainActor
protocol OnboardingCompletedUseCaseProtocol {
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: any LoggableEvent)
}
