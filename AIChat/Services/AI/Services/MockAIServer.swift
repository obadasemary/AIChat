//
//  MockAIServer.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import SwiftUI

struct MockAIServer: AIServiceProtocol {
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "gear")!
    }
}
