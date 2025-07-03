//
//  ABTestManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.07.2025.
//

import Foundation

protocol ABTestServiceProtocol {
    
}

struct MockABTestService: ABTestServiceProtocol {
    
}

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestServiceProtocol
    
    init(service: ABTestServiceProtocol) {
        self.service = service
    }
}
