//
//  ActiveABTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation

struct ActiveABTests: Codable {
    
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20250702_CreateAccTest"
        case onboardingCommunityTest = "_20250702_OnbCommunityTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest
        ]
        return dict.compactMapValues { $0 }
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
}
