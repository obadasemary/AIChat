//
//  ABTestServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
//

import Foundation

protocol ABTestServiceProtocol {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTest: ActiveABTests) throws
}
