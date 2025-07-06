//
//  MockABTestService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation

class MockABTestService {
    
    var activeTests: ActiveABTests
    
    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false
        )
    }
}

extension MockABTestService: ABTestServiceProtocol {
    
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        activeTests = updatedTest
    }
}
