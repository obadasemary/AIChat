//
//  EntitlementOwnershipOption.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import Foundation
import StoreKit

public enum EntitlementOwnershipOption: Codable, Sendable {
    case purchased, familyShared, unknown
}

extension EntitlementOwnershipOption {
    
    init(type: Transaction.OwnershipType) {
        switch type {
        case .purchased:
            self = .purchased
        case .familyShared:
            self = .familyShared
        default:
            self = .unknown
        }
    }
}
