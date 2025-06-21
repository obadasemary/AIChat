//
//  AIChatModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

import Foundation
import OpenAI

struct AIChatModel: Codable {
    
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, message: String) {
        self.role = role
        self.message = message
    }
    
    init?(chat: ChatResult.Choice.ChatCompletionMessage) {
        self.role = AIChatRole(role: chat.role)
        if let string = chat.content?.string {
            self.message = string
        } else {
            return nil
        }
    }
    
    func toOpenAIModel() -> ChatQuery.ChatCompletionMessageParam? {
        ChatQuery.ChatCompletionMessageParam(
            role: role.openAIRole,
            content: [ChatContent.chatCompletionContentPartTextParam(ChatText(text: message))]
        )
    }
}
