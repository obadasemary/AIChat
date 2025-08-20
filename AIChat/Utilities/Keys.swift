//
//  Keys.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct Keys {
    static let openAIAPIKey: String = {
        let key = ConfigurationManager.shared.openAIAPIKey
        print("🔑 Keys: OpenAI API Key loaded: \(key.isEmpty ? "EMPTY" : "\(String(key.prefix(8)))...")")
        return key
    }()
    
    static let mixpanelToken: String = {
        let token = ConfigurationManager.shared.mixpanelToken
        print("🔑 Keys: Mixpanel Token loaded: \(token.isEmpty ? "EMPTY" : "\(String(token.prefix(8)))...")")
        return token
    }()
}