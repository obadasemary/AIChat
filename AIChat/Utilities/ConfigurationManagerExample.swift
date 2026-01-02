//
//  ConfigurationManagerExample.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.12.2025.
//
//  This file demonstrates how to use both ConfigurationManager and EnhancedConfigurationManager
//

import Foundation

// MARK: - Example Usage

/// Example showing how to use the legacy ConfigurationManager (iOS 17.6+)
func exampleLegacyConfiguration() {
    let openAIKey = ConfigurationManager.shared.openAIAPIKey
    let mixpanelToken = ConfigurationManager.shared.mixpanelToken
    let isValid = ConfigurationManager.shared.isConfigurationValid

    print("OpenAI Key: \(openAIKey.isEmpty ? "Not configured" : "Configured")")
    print("Mixpanel Token: \(mixpanelToken.isEmpty ? "Not configured" : "Configured")")
    print("Configuration Valid: \(isValid)")
}

/// Example showing how to use the new EnhancedConfigurationManager (iOS 18.0+)
@available(iOS 18.0, *)
func exampleEnhancedConfiguration() async {
    let manager = EnhancedConfigurationManager.shared

    // Read configuration values (async)
    let openAIKey = await manager.openAIAPIKey
    let mixpanelToken = await manager.mixpanelToken
    let newsAPIKey = await manager.newsAPIKey

    print("OpenAI Key: \(openAIKey.isEmpty ? "Not configured" : "Configured")")
    print("Mixpanel Token: \(mixpanelToken.isEmpty ? "Not configured" : "Configured")")
    print("News API Key: \(newsAPIKey.isEmpty ? "Not configured" : "Configured")")

    // Validate configuration
    let isValid = await manager.isConfigurationValid
    print("Configuration Valid: \(isValid)")

    // Get Firebase configuration path
    let firebasePath = manager.getFirebaseConfigPath(for: .dev)
    print("Firebase Config Path: \(firebasePath ?? "Not found")")
}

// MARK: - Migration Guide

/*
 Migration from ConfigurationManager to EnhancedConfigurationManager:

 Before (iOS 17.6+):
 ```swift
 let key = ConfigurationManager.shared.openAIAPIKey
 ```

 After (iOS 18.0+):
 ```swift
 let key = await EnhancedConfigurationManager.shared.openAIAPIKey
 ```

 Key Differences:
 1. EnhancedConfigurationManager methods are async
 2. It's an actor, so all access is thread-safe
 3. Supports hot-reloading for dynamic configuration updates
 4. Provider hierarchy is more explicit and extensible

 Recommendation:
 - Use ConfigurationManager for iOS 17.6 support
 - Use EnhancedConfigurationManager when targeting iOS 18.0+
 - Consider using availability checks to support both:

 ```swift
 func getAPIKey() async -> String {
     if #available(iOS 18.0, *) {
         return await EnhancedConfigurationManager.shared.openAIAPIKey
     } else {
         return ConfigurationManager.shared.openAIAPIKey
     }
 }
 ```
 */
