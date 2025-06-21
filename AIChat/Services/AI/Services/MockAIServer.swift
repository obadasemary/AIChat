//
//  MockAIServer.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import SwiftUI

struct MockAIServer {
    
    let delay: Double
    let showError: Bool
    
    init(
        delay: Double = 0.0,
        showError: Bool = false
    ) {
        self.delay = delay
        self.showError = showError
    }
}

extension MockAIServer: AIServiceProtocol {
    
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        let (data, _) = try await URLSession.shared.data(from: URL(string: Constants.randomImage)!)
        guard let image = UIImage(data: data) else {
            return UIImage(systemName: "gear")!
        }
        
        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return AIChatModel(
            role: .assistant,
            message: "This is returned text from the mock server AI."
        )
    }
}

private extension MockAIServer {
    func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
