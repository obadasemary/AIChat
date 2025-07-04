//
//  ABTestManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.07.2025.
//

import Foundation

struct ActiveABTest: Codable {
    
    let createAccountTest: Bool
    
    init(createAccountTest: Bool) {
        self.createAccountTest = createAccountTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_20250702_createAccTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest
        ]
        return dict.compactMapValues { $0 }
    }
}

protocol ABTestServiceProtocol {
    var activeTests: ActiveABTest { get }
}

struct MockABTestService {
    
    let activeTests: ActiveABTest
    
    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTest(
            createAccountTest: createAccountTest ?? false
        )
    }
}

extension MockABTestService: ABTestServiceProtocol {}

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestServiceProtocol
    private let logManager: LogManagerProtocol?
    
    var activeTests: ActiveABTest
    
    init(
        service: ABTestServiceProtocol,
        logManager: LogManagerProtocol? = nil
    ) {
        self.service = service
        self.logManager = logManager
        self.activeTests = service.activeTests
        self.configure()
    }
    
    private func configure() {
        logManager?
            .addUserProperties(
                dict: activeTests.eventParameters,
                isHighPriority: false
            )
    }
}
