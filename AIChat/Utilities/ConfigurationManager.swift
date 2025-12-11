//
//  ConfigurationManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 20.10.2025.
//

import Foundation

/// Configuration manager for handling API keys and other sensitive configuration
struct ConfigurationManager {
    
    // MARK: - Singleton
    static let shared = ConfigurationManager()
    
    // MARK: - Private Properties
    private let configFileName = "Config"
    private let configFileExtension = "plist"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Configuration Loading
    private var configuration: [String: Any]? {
        // Try to find the config file in the main bundle using the same pattern as other plists
        if let path = Bundle.main.path(forResource: configFileName, ofType: configFileExtension) {
            print("📱 ConfigurationManager: Found Config.plist at: \(path)")
            if let plist = NSDictionary(contentsOfFile: path) as? [String: Any] {
                print("📱 ConfigurationManager: Successfully loaded configuration")
                return plist
            } else {
                print("❌ ConfigurationManager: Failed to parse Config.plist")
            }
        } else {
            print("❌ ConfigurationManager: Config.plist not found in main bundle")
            
            // Debug: List all resources in the main bundle
            if let resources = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
                print("📱 ConfigurationManager: Available resources in bundle:")
                for resource in resources {
                    print("   - \(resource.lastPathComponent)")
                }
            }
        }
        return nil
    }
    
    // MARK: - Firebase Configuration
    func getFirebaseConfigPath(for environment: BuildConfiguration) -> String? {
        let fileName: String
        switch environment {
        case .dev:
            fileName = "GoogleService-Info-Dev"
        case .prod:
            fileName = "GoogleService-Info-Prod"
        case .mock:
            return nil
        }
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist") {
            print("📱 ConfigurationManager: Found Firebase config for \(environment) at: \(path)")
            return path
        } else {
            print("❌ ConfigurationManager: Firebase config for \(environment) not found")
            return nil
        }
    }
    
    // MARK: - API Keys
    var openAIAPIKey: String {
        // First try to get from environment variable (for CI/CD)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            print("📱 ConfigurationManager: Using OpenAI API key from environment variable")
            return envKey
        }
        
        // Then try to get from configuration file
        if let config = configuration,
           let apiKey = config["OpenAIAPIKey"] as? String,
           !apiKey.isEmpty && apiKey != "YOUR_OPENAI_API_KEY_HERE" {
            print("📱 ConfigurationManager: Using OpenAI API key from Config.plist")
            return apiKey
        }
        
        print("❌ ConfigurationManager: No valid OpenAI API key found")
        // Fallback to empty string if not configured
        return ""
    }
    
    var mixpanelToken: String {
        // First try to get from environment variable (for CI/CD)
        if let envKey = ProcessInfo.processInfo.environment["MIXPANEL_TOKEN"], !envKey.isEmpty {
            print("📱 ConfigurationManager: Using Mixpanel token from environment variable")
            return envKey
        }
        
        // Then try to get from configuration file
        if let config = configuration,
           let token = config["MixpanelToken"] as? String,
           !token.isEmpty && token != "YOUR_MIXPANEL_TOKEN_HERE" {
            print("📱 ConfigurationManager: Using Mixpanel token from Config.plist")
            return token
        }
        
        print("❌ ConfigurationManager: No valid Mixpanel token found")
        // Fallback to empty string if not configured
        return ""
    }
    
    var newsAPIKey: String {
        if let envKey = ProcessInfo.processInfo.environment["NEWSAPI_API_KEY"], !envKey.isEmpty {
            print("📱 ConfigurationManager: Using NewsAPI key from environment variable")
            return envKey
        }
        
        if let config = configuration,
           let token = config["NewsAPIKey"] as? String,
           !token.isEmpty && token != "YOUR_NEWSAPI_API_KEY_HERE" {
            print("📱 ConfigurationManager: Using NewsAPI token from Config.plist")
            return token
        }
        
        print("❌ ConfigurationManager: No valid NewsAPI token found")
        return ""
    }
    
    // MARK: - Validation
    var isConfigurationValid: Bool {
        let isValid = !openAIAPIKey.isEmpty && !mixpanelToken.isEmpty
        print("📱 ConfigurationManager: Configuration valid: \(isValid)")
        return isValid
    }
    
    // MARK: - Configuration Instructions
    static let setupInstructions = """
    To configure your API keys:
    
    1. Copy Config.template.plist to Config.plist
    2. Fill in your actual API keys in Config.plist
    3. Make sure Config.plist is added to your Xcode project bundle
    
    For Firebase configuration:
    1. Copy GoogleService-Info-Dev.template.plist to GoogleService-Info-Dev.plist
    2. Copy GoogleService-Info-Prod.template.plist to GoogleService-Info-Prod.plist
    3. Fill in your actual Firebase configuration values
    4. Make sure both plist files are added to your Xcode project bundle
    
    Alternatively, you can set environment variables:
    - OPENAI_API_KEY
    - MIXPANEL_TOKEN
    
    Note: All configuration plist files are already added to .gitignore to prevent committing sensitive data.
    
    For new developers: See README.md for detailed setup instructions.
    """
}
