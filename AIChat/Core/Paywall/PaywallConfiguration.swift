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

    func updateOption(_ option: PaywallOptional) {
        currentOption = option
    }
}
