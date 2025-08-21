//
//  ActiveABTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation
import FirebaseRemoteConfig

struct ActiveABTests: Codable {
    
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOption
    private(set) var paywallOption: PaywallOptional
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption,
        paywallOption: PaywallOptional = .custom
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
        self.paywallOption = paywallOption
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20250720_CreateAccTest"
        case onboardingCommunityTest = "_20250720_OnbCommunityTest"
        case categoryRowTest = "_20250720_CateegoryRowTest"
        case paywallOption = "_20250720_PaywallOption"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue,
            "test\(CodingKeys.paywallOption.rawValue)": paywallOption.rawValue
        ]
        return dict.compactMapValues { $0 }
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
    
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categoryRowTest = newValue
    }
    
    mutating func update(paywallOption newValue: PaywallOptional) {
        paywallOption = newValue
    }
}

// MARK: REMOTE CONFIG

extension ActiveABTests {
    
    init(config: RemoteConfig) {
        let createAccountTest = config.configValue(
            forKey: ActiveABTests.CodingKeys.categoryRowTest.rawValue
        ).boolValue
        print("FOUND CREATE ACCOUNT DATA: \(createAccountTest)")
        self.createAccountTest = createAccountTest
        
        let onboardingCommunityTest = config.configValue(
            forKey: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue
        ).boolValue
        self.onboardingCommunityTest = onboardingCommunityTest
        
        let categoryRowTestStringValue = config.configValue(
            forKey: ActiveABTests.CodingKeys.categoryRowTest.rawValue
        ).stringValue
        if let option = CategoryRowTestOption(rawValue: categoryRowTestStringValue) {
            self.categoryRowTest = option
        } else {
            self.categoryRowTest = .default
        }
        
        let paywallOptionStringValue = config.configValue(
            forKey: ActiveABTests.CodingKeys.paywallOption.rawValue
        ).stringValue
        if let option = PaywallOptional(rawValue: paywallOptionStringValue) {
            self.paywallOption = option
        } else {
            self.paywallOption = .custom
        }
    }
    
    // Converted to a NSObject dictionary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String : NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject,
            CodingKeys.paywallOption.rawValue: paywallOption.rawValue as NSObject
        ]
    }
}
