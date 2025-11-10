//
//  PaywallConfiguration.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import Foundation

@Observable
@MainActor
final class PaywallConfiguration {
    static let shared = PaywallConfiguration()

    var currentOption: PaywallOptional

    private init() {
        // Load saved value from UserDefaults
        let savedValue = UserDefaults.standard.string(
            forKey: ActiveABTests.CodingKeys.paywallOption.rawValue
        )
        self.currentOption = PaywallOptional(rawValue: savedValue ?? "") ?? .custom
    }

    /// Updates the current paywall option in memory.
    ///
    /// - Warning: This method only updates the in-memory value and does NOT persist to UserDefaults.
    /// For persistent changes, use `DevSettingsViewModel.handlePaywallOptionChange()` which saves
    /// through the AB test system.
    ///
    /// - Parameter option: The new paywall option to set
    func updateOption(_ option: PaywallOptional) {
        currentOption = option
    }
}
