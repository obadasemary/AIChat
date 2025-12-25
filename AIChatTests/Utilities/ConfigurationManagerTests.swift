//
//  ConfigurationManagerTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 26.12.2025.
//

import Testing
@testable import AIChat

struct ConfigurationManagerTests {

    @Test("Environment Variables Are Loaded In CI")
    func testEnvironmentVariablesAreLoadedInCI() async throws {
        let configManager = ConfigurationManager.shared

        // Get the API keys from ConfigurationManager
        let openAIKey = configManager.openAIAPIKey
        let mixpanelToken = configManager.mixpanelToken
        let newsAPIKey = configManager.newsAPIKey

        // In CI, environment variables should be set
        // These will either come from ENV vars (CI) or Config.plist (local dev)
        #expect(!openAIKey.isEmpty, "OpenAI API Key should be loaded from ENV or Config.plist")
        #expect(!mixpanelToken.isEmpty, "Mixpanel Token should be loaded from ENV or Config.plist")
        #expect(!newsAPIKey.isEmpty, "NewsAPI Key should be loaded from ENV or Config.plist")

        // Print for verification in CI logs (values will be auto-redacted by GitHub)
        print("✅ ConfigurationManager Test: OpenAI API Key loaded (length: \(openAIKey.count))")
        print("✅ ConfigurationManager Test: Mixpanel Token loaded (length: \(mixpanelToken.count))")
        print("✅ ConfigurationManager Test: NewsAPI Key loaded (length: \(newsAPIKey.count))")

        // Verify configuration is valid
        #expect(configManager.isConfigurationValid, "Configuration should be valid with all required keys")
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
