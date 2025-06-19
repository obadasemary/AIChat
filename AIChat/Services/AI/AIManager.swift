//
//  AIManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import SwiftUI

@MainActor
@Observable
final class AIManager {
    
    private let service: AIServiceProtocol
    
    init(service: AIServiceProtocol) {
        self.service = service
    }
}

extension AIManager: AIManagerProtocol {
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await service.generateText(chats: chats)
    }
}

private extension AIManager {}
