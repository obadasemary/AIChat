//
//  WelcomeUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol WelcomeUseCaseProtocol {
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: any LoggableEvent)
}
