//
//  LocalABTestService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation

class LocalABTestService {
    
    @UserDefault(
        key: ActiveABTests.CodingKeys.createAccountTest.rawValue,
        defaultValue: .random()
    ) private var createAccountTest: Bool
    
    @UserDefault(
        key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue,
        defaultValue: .random()
    ) private var onboardingCommunityTest: Bool
    
    @UserDefaultِEnum(
        key: ActiveABTests.CodingKeys.categoryRowTest.rawValue,
        defaultValue: CategoryRowTestOption.allCases.randomElement()!
    ) private var categoryRowTest: CategoryRowTestOption
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categoryRowTest: categoryRowTest
        )
    }
}

extension LocalABTestService: ABTestServiceProtocol {
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        createAccountTest = updatedTest.createAccountTest
        onboardingCommunityTest = updatedTest.onboardingCommunityTest
        categoryRowTest = updatedTest.categoryRowTest
    }
}
