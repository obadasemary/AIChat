//
//  Keys.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation
import Configuration

struct Keys {
    // MARK: - Primary Synchronous API (uses Swift Configuration on iOS 18.0+)

    static let openAIAPIKey: String = {
        if #available(iOS 18.0, *) {
            print("🔍 Keys: Checking environment variable OPENAI_API_KEY via Swift Configuration...")
            // Use Swift Configuration's ConfigReader for environment variable support
            let envReader = ConfigReader(provider: EnvironmentVariablesProvider())
            if let envKey = envReader.string(forKey: "OPENAI_API_KEY"), !envKey.isEmpty {
                print("✅ Keys: OpenAI API Key loaded from ENV: \(String(envKey.prefix(8)))...")
                return envKey
            }
            print("⚠️ Keys: OPENAI_API_KEY not found in environment, falling back to Config.plist")
        }

        // Fallback to ConfigurationManager (Config.plist)
        let key = ConfigurationManager.shared.openAIAPIKey
        print("🔑 Keys: OpenAI API Key loaded from Config: \(key.isEmpty ? "EMPTY" : "\(String(key.prefix(8)))...")")
        return key
    }()

    static let mixpanelToken: String = {
        if #available(iOS 18.0, *) {
            print("🔍 Keys: Checking environment variable MIXPANEL_TOKEN via Swift Configuration...")
            let envReader = ConfigReader(provider: EnvironmentVariablesProvider())
            if let envToken = envReader.string(forKey: "MIXPANEL_TOKEN"), !envToken.isEmpty {
                print("✅ Keys: Mixpanel Token loaded from ENV: \(String(envToken.prefix(8)))...")
                return envToken
            }
            print("⚠️ Keys: MIXPANEL_TOKEN not found in environment, falling back to Config.plist")
        }

        let token = ConfigurationManager.shared.mixpanelToken
        print("🔑 Keys: Mixpanel Token loaded from Config: \(token.isEmpty ? "EMPTY" : "\(String(token.prefix(8)))...")")
        return token
    }()

    static let newsAPIKey: String = {
        if #available(iOS 18.0, *) {
            print("🔍 Keys: Checking environment variable NEWSAPI_API_KEY via Swift Configuration...")
            let envReader = ConfigReader(provider: EnvironmentVariablesProvider())
            if let envKey = envReader.string(forKey: "NEWSAPI_API_KEY"), !envKey.isEmpty {
                print("✅ Keys: News API Key loaded from ENV: \(String(envKey.prefix(8)))...")
                return envKey
            }
            print("⚠️ Keys: NEWSAPI_API_KEY not found in environment, falling back to Config.plist")
        }

        let key = ConfigurationManager.shared.newsAPIKey
        print("🔑 Keys: News API Key loaded from Config: \(key.isEmpty ? "EMPTY" : "\(String(key.prefix(8)))...")")
        return key
    }()

    // MARK: - Async API (iOS 18.0+) - for when you need async context

    @MainActor
    @available(iOS 18.0, *)
    static func getOpenAIAPIKey() async -> String {
        let key = await EnhancedConfigurationManager.shared.openAIAPIKey
        print("🔑 Keys (Async): OpenAI API Key loaded: \(key.isEmpty ? "EMPTY" : "\(String(key.prefix(8)))...")")
        return key
    }

    @MainActor
    @available(iOS 18.0, *)
    static func getMixpanelToken() async -> String {
        let token = await EnhancedConfigurationManager.shared.mixpanelToken
        print("🔑 Keys (Async): Mixpanel Token loaded: \(token.isEmpty ? "EMPTY" : "\(String(token.prefix(8)))...")")
        return token
    }

    @MainActor
    @available(iOS 18.0, *)
    static func getNewsAPIKey() async -> String {
        let key = await EnhancedConfigurationManager.shared.newsAPIKey
        print("🔑 Keys (Async): News API Key loaded: \(key.isEmpty ? "EMPTY" : "\(String(key.prefix(8)))...")")
        return key
    }
}
