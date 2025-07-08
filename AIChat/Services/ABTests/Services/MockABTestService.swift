//
//  MockABTestService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation

@MainActor
class MockABTestService {
    
    var activeTests: ActiveABTests
    
    init(
        createAccountTest: Bool? = nil,
        onboardingCommunityTest: Bool? = nil,
        categoryRowTest: CategoryRowTestOption? = nil
    ) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false,
            categoryRowTest: categoryRowTest ?? .default
        )
    }
}

extension MockABTestService: ABTestServiceProtocol {
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        activeTests = updatedTest
    }
    
    func fetchUpdateConfig() async throws -> ActiveABTests {
        activeTests
    }
}
