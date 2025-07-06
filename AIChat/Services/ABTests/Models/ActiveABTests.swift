//
//  ActiveABTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.07.2025.
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
