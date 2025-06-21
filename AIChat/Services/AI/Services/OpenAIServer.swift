//
//  OpenAIServer.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import SwiftUI
@preconcurrency import OpenAI

struct OpenAIServer {
    
    private let openAI: OpenAI
    
    init(openAI: OpenAI = OpenAI(apiToken: Keys.openAIAPIKey)) {
        self.openAI = openAI
    }
}

extension OpenAIServer: AIServiceProtocol {
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            n: 1,
            size: ._512
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        
        let messages = chats.compactMap({ $0.toOpenAIModel() })
        
        let query = ChatQuery(
            messages: messages,
            model: .gpt3_5Turbo
        )
            
        do {
            let result = try await openAI.chats(query: query)
            guard
                let chat = result.choices.first?.message,
                let model = AIChatModel(chat: chat)
            else {
                throw OpenAIError.invalidResponse
            }
            print("Returned Message: \(String(describing: chat.content))")
            return model
        } catch {
            print("Error decoding chat response: \(error)")
            throw error
        }
    }
}

private extension OpenAIServer {
    enum OpenAIError: LocalizedError {
        case invalidPrompt
        case invalidURL
        case invalidResponse
        case decodingFailed
    }
    
    func generateTextWithOAIV043(input: String) async throws {
        
        let query = ChatQuery(
            messages: [
                .user(.init(content: .string(input)))
            ],
            model: .gpt4_o
        )
        
        do {
            let result = try await openAI.chats(query: query)
            guard let chat = result.choices.first?.message else {
                throw OpenAIError.invalidResponse
            }
            print("Returned Message: \(String(describing: chat.content))")
        } catch {
            print("Error decoding chat response: \(error)")
            throw error
        }
    }
    
    func generateImageWithAPI(input: String) async throws -> UIImage {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OpenAIError.invalidPrompt
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Keys.openAIAPIKey)", forHTTPHeaderField: "Authorization")

        let payload = OpenAIImageRequest(prompt: input)
//        let payload = OpenAIImageRequest(prompt: "A futuristic city skyline at sunset, digital art")
//        let bodyData = try JSONEncoder().encode(payload)
//        print(String(data: bodyData, encoding: .utf8) ?? "Encoding failed")
//        request.httpBody = bodyData
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        print("Response status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unreadable")")
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OpenAIError.invalidResponse
        }
        
        print("Response status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unreadable")")

        let decoded = try JSONDecoder().decode(OpenAIImageResponse.self, from: data)
        guard let b64Json = decoded.data.first?.b64_json,
              let imageData = Data(base64Encoded: b64Json),
              let image = UIImage(data: imageData) else {
            throw OpenAIError.invalidResponse
        }

        return image
    }
    
    struct OpenAIImageRequest: Encodable {
        let prompt: String
        let n: Int
        let size: String
        let response_format: String
        
        init(prompt: String, n: Int = 1, size: String = "512x512", response_format: String = "b64_json") {
            self.prompt = prompt
            self.n = n
            self.size = size
            self.response_format = response_format
        }
    }

    struct OpenAIImageResponse: Decodable {
        struct ImageData: Decodable {
            let b64_json: String
        }
        let data: [ImageData]
    }
}
