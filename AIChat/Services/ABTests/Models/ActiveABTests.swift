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
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20250720_CreateAccTest"
        case onboardingCommunityTest = "_20250720_OnbCommunityTest"
        case categoryRowTest = "_20250720_CateegoryRowTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue
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
}

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original
    case top
    case hidden
    
    static var `default`: Self {
        .original
    }
}

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
    }
    
    // Converted to a NSObject dictionary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String : NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject
        ]
    }
}
