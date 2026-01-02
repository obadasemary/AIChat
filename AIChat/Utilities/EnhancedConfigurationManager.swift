//
//  EnhancedConfigurationManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.12.2025.
//

import Foundation
import Configuration

/// Enhanced configuration manager using Apple's Swift Configuration library
/// Provides provider hierarchy and modern async/await API
@available(iOS 18.0, *)
actor EnhancedConfigurationManager {

    // MARK: - Singleton
    static let shared = EnhancedConfigurationManager()

    // MARK: - Properties
    private var reader: ConfigReader

    // MARK: - Initialization
    private init() {
        // For now, use a simple setup with environment variables and fallback to ConfigurationManager
        // This demonstrates the Swift Configuration API while maintaining compatibility
        self.reader = ConfigReader(provider: EnvironmentVariablesProvider())
    }

    // MARK: - Configuration Access

    var openAIAPIKey: String {
        get async {
            // Try Swift Configuration first (environment variables)
            let envKey = reader.string(forKey: "OPENAI_API_KEY", default: "")

            // Fall back to legacy ConfigurationManager if needed
            if !envKey.isEmpty {
                print("📱 EnhancedConfigurationManager: Using OpenAI API key from environment variable")
                return envKey
            }

            // Fallback to legacy manager
            let legacyKey = ConfigurationManager.shared.openAIAPIKey
            if !legacyKey.isEmpty {
                print("📱 EnhancedConfigurationManager: Using OpenAI API key from ConfigurationManager")
            }
            return legacyKey
        }
    }

    var mixpanelToken: String {
        get async {
            let envToken = reader.string(forKey: "MIXPANEL_TOKEN", default: "")

            if !envToken.isEmpty {
                print("📱 EnhancedConfigurationManager: Using Mixpanel token from environment variable")
                return envToken
            }

            let legacyToken = ConfigurationManager.shared.mixpanelToken
            if !legacyToken.isEmpty {
                print("📱 EnhancedConfigurationManager: Using Mixpanel token from ConfigurationManager")
            }
            return legacyToken
        }
    }

    var newsAPIKey: String {
        get async {
            let envKey = reader.string(forKey: "NEWSAPI_API_KEY", default: "")

            if !envKey.isEmpty {
                print("📱 EnhancedConfigurationManager: Using NewsAPI key from environment variable")
                return envKey
            }

            let legacyKey = ConfigurationManager.shared.newsAPIKey
            if !legacyKey.isEmpty {
                print("📱 EnhancedConfigurationManager: Using NewsAPI key from ConfigurationManager")
            }
            return legacyKey
        }
    }

    // MARK: - Firebase Configuration

    nonisolated func getFirebaseConfigPath(for environment: BuildConfiguration) -> String? {
        ConfigurationManager.shared.getFirebaseConfigPath(for: environment)
    }

    // MARK: - Validation

    var isConfigurationValid: Bool {
        get async {
            let openAI = await openAIAPIKey
            let mixpanel = await mixpanelToken
            let isValid = !openAI.isEmpty && !mixpanel.isEmpty
            print("📱 EnhancedConfigurationManager: Configuration valid: \(isValid)")
            return isValid
        }
    }

    // MARK: - Setup Instructions

    nonisolated static let setupInstructions = """
    To configure your API keys with Swift Configuration:

    1. Copy Config.template.plist to Config.plist
    2. Fill in your actual API keys in Config.plist
    3. Make sure Config.plist is added to your Xcode project bundle

    For Firebase configuration:
    1. Copy GoogleService-Info-Dev.template.plist to GoogleService-Info-Dev.plist
    2. Copy GoogleService-Info-Prod.template.plist to GoogleService-Info-Prod.plist
    3. Fill in your actual Firebase configuration values
    4. Make sure both plist files are added to your Xcode project bundle

    Environment variables (highest priority):
    - OPENAI_API_KEY
    - MIXPANEL_TOKEN
    - NEWSAPI_API_KEY

    Note: All configuration plist files are already added to .gitignore to prevent committing sensitive data.

    Features:
    - Environment variable support via Swift Configuration
    - Fallback to Config.plist via ConfigurationManager
    - Async/await support for all configuration reads
    - Thread-safe access via actor isolation

    For new developers: See README.md for detailed setup instructions.
    """
}
