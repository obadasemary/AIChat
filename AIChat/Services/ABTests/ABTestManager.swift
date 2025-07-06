//
//  ABTestManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.07.2025.
//

import Foundation

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
