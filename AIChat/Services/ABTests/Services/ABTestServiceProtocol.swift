//
//  ABTestServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation

@MainActor
protocol ABTestServiceProtocol: Sendable {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
