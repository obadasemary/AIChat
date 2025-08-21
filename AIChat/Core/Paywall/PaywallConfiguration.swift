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
    
    var currentOption: PaywallOptional = .custom
    
    private init() {}
    
    func updateOption(_ option: PaywallOptional) {
        currentOption = option
    }
}
