//
//  LocalABTestService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation

@MainActor
class LocalABTestService {
    
    @UserDefault(
        key: ActiveABTests.CodingKeys.createAccountTest.rawValue,
        defaultValue: .random()
    ) private var createAccountTest: Bool

    @UserDefault(
        key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue,
        defaultValue: .random()
    ) private var onboardingCommunityTest: Bool

    // swiftlint:disable force_unwrapping
    @UserDefaultEnum(
        key: ActiveABTests.CodingKeys.categoryRowTest.rawValue,
        defaultValue: CategoryRowTestOption.allCases.randomElement()!
    ) private var categoryRowTest: CategoryRowTestOption
    // swiftlint:enable force_unwrapping

    @UserDefaultEnum(
        key: ActiveABTests.CodingKeys.paywallOption.rawValue,
        defaultValue: .custom
    ) private var paywallOption: PaywallOptional

    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categoryRowTest: categoryRowTest,
            paywallOption: paywallOption
        )
    }
}

extension LocalABTestService: ABTestServiceProtocol {
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        createAccountTest = updatedTest.createAccountTest
        onboardingCommunityTest = updatedTest.onboardingCommunityTest
        categoryRowTest = updatedTest.categoryRowTest
        paywallOption = updatedTest.paywallOption
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
