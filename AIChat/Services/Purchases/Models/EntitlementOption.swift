//
//  EntitlementOption.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.07.2025.
//

import Foundation

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    case monthly
    
    var productId: String {
        switch self {
        case .yearly:
            return "com.Obada.AIChat.yearly"
        case .monthly:
            return "com.Obada.AIChat.monthly"
        }
    }
    
    static var allProductIds: [String] {
        EntitlementOption.allCases.map({ $0.productId })
    }
}
