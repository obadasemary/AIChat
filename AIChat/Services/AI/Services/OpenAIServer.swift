//
//  OpenAIServer.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import SwiftUI
import OpenAI

struct OpenAIServer {
    
    private let openAI: OpenAI
    
    init(openAI: OpenAI = OpenAI(apiToken: "")) {
        self.openAI = openAI
    }
}

extension OpenAIServer: AIServiceProtocol {
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            n: 1,
            size: ._1024
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json, options: .ignoreUnknownCharacters),
              let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
}

private extension OpenAIServer {
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}
