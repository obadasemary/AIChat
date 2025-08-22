//
//  PaywallModels.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import Foundation

public enum PaywallOptional: String, Codable, CaseIterable {
    case custom = "Custom"
    case storeKit = "StoreKit"
    
    static var `default`: Self {
        .custom
    }
}
