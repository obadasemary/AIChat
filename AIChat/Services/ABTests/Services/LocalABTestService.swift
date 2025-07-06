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
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest
        )
    }
}

extension LocalABTestService: ABTestServiceProtocol {
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        createAccountTest = updatedTest.createAccountTest
    }
}
