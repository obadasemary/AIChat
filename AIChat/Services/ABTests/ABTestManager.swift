//
//  ABTestManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.07.2025.
//

import Foundation

struct ActiveABTests: Codable {
    
    private(set) var createAccountTest: Bool
    
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
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
}

protocol ABTestServiceProtocol {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws
}

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

protocol ABTestManagerProtocol {
    func override(updateTests: ActiveABTests) throws
}

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestServiceProtocol
    private let logManager: LogManagerProtocol?
    
    var activeTests: ActiveABTests
    
    init(
        service: ABTestServiceProtocol,
        logManager: LogManagerProtocol? = nil
    ) {
        self.service = service
        self.logManager = logManager
        self.activeTests = service.activeTests
        self.configure()
    }
    
}

extension ABTestManager: @preconcurrency ABTestManagerProtocol {
    
    func override(updateTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTest: updateTests)
        configure()
    }
}

private extension ABTestManager {
    
    func configure() {
        activeTests = service.activeTests
        logManager?
            .addUserProperties(
                dict: activeTests.eventParameters,
                isHighPriority: false
            )
    }
}
