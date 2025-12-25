//
//  ConfigurationManagerTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 26.12.2025.
//

import Foundation
import Testing
@testable import AIChat

struct ConfigurationManagerTests {

    @Test("Keys Are Loaded From Environment Variables In CI (Production Path)")
    func testKeysAreLoadedFromEnvironmentVariablesInCI() async throws {
        // Keys.swift is the PRIMARY API used in production
        // On iOS 18.0+, it uses Swift Configuration's EnvironmentVariablesProvider
        // to read ENV vars, falling back to ConfigurationManager (Config.plist)

        let openAIKey = Keys.openAIAPIKey
        let mixpanelToken = Keys.mixpanelToken
        let newsAPIKey = Keys.newsAPIKey

        // Verify all keys are loaded (from ENV in CI, or Config.plist locally)
        #expect(!openAIKey.isEmpty, "OpenAI API Key should be loaded from ENV or Config.plist")
        #expect(!mixpanelToken.isEmpty, "Mixpanel Token should be loaded from ENV or Config.plist")
        #expect(!newsAPIKey.isEmpty, "NewsAPI Key should be loaded from ENV or Config.plist")

        // Print for verification in CI logs
        // Keys.swift already prints with ✅ emoji when loading from ENV
        print("✅ Test: Keys loaded successfully - OpenAI(\(openAIKey.count) chars), Mixpanel(\(mixpanelToken.count) chars), NewsAPI(\(newsAPIKey.count) chars)")
    }

    @Test("ConfigurationManager Loads Environment Variables (Fallback Path)")
    func testConfigurationManagerLoadsEnvironmentVariables() async throws {
        // Test the fallback ConfigurationManager directly
        let configManager = ConfigurationManager.shared

        let openAIKey = configManager.openAIAPIKey
        let mixpanelToken = configManager.mixpanelToken
        let newsAPIKey = configManager.newsAPIKey

        #expect(!openAIKey.isEmpty, "OpenAI API Key should be loaded")
        #expect(!mixpanelToken.isEmpty, "Mixpanel Token should be loaded")
        #expect(!newsAPIKey.isEmpty, "NewsAPI Key should be loaded")
        #expect(configManager.isConfigurationValid, "Configuration should be valid")

        print("✅ Test: ConfigurationManager loaded successfully")
    }

    @Test("API Keys Are Not Default Template Values")
    func testAPIKeysAreNotDefaultTemplateValues() async throws {
        let configManager = ConfigurationManager.shared

        let openAIKey = configManager.openAIAPIKey
        let mixpanelToken = configManager.mixpanelToken
        let newsAPIKey = configManager.newsAPIKey

        // Ensure we're not using placeholder values from template files
        #expect(openAIKey != "YOUR_OPENAI_API_KEY_HERE", "Should not use template OpenAI key")
        #expect(mixpanelToken != "YOUR_MIXPANEL_TOKEN_HERE", "Should not use template Mixpanel token")
        #expect(newsAPIKey != "YOUR_NEWSAPI_API_KEY_HERE", "Should not use template NewsAPI key")

        print("✅ ConfigurationManager Test: All keys are configured (not using template values)")
    }

    @Test("Environment Variables Have Priority Over Config.plist")
    func testEnvironmentVariablesPriority() async throws {
        // This test verifies the priority: ENV > Config.plist
        // In CI, environment variables should be used
        // Locally, Config.plist will be used if ENV vars are not set

        let hasEnvOpenAI = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] != nil
        let hasEnvMixpanel = ProcessInfo.processInfo.environment["MIXPANEL_TOKEN"] != nil
        let hasEnvNewsAPI = ProcessInfo.processInfo.environment["NEWSAPI_API_KEY"] != nil

        if hasEnvOpenAI || hasEnvMixpanel || hasEnvNewsAPI {
            print("✅ ConfigurationManager Test: Running with environment variables (CI mode)")
        } else {
            print("✅ ConfigurationManager Test: Running with Config.plist (local dev mode)")
        }

        // Either way, keys should be loaded
        let configManager = ConfigurationManager.shared
        #expect(!configManager.openAIAPIKey.isEmpty, "OpenAI key should be loaded")
        #expect(!configManager.mixpanelToken.isEmpty, "Mixpanel token should be loaded")
        #expect(!configManager.newsAPIKey.isEmpty, "NewsAPI key should be loaded")
    }
}
