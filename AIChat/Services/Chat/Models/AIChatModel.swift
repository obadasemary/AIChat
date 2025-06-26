//
//  AIChatModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

import Foundation
import OpenAI

typealias ChatCompletion = ChatQuery.ChatCompletionMessageParam
typealias SystemMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionSystemMessageParam
typealias UserMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam
typealias UserTextContent = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content
typealias AssistantMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionAssistantMessageParam

struct AIChatModel: Codable {
    
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, message: String) {
        self.role = role
        self.message = message
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case message
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "aichat_\(CodingKeys.role.rawValue)": role.rawValue,
            "aichat_\(CodingKeys.message.rawValue)": message,
        ]
        return dict.compactMapValues { $0 }
    }
    
    init?(chat: ChatResult.Choice.ChatCompletionMessage) {
        self.role = AIChatRole(role: chat.role)
        if let string = chat.content?.string {
            self.message = string
        } else {
            return nil
        }
    }
    
    func toOpenAIModel() -> ChatCompletion? {
        
        switch role {
        case .system:
            return ChatCompletion.system(SystemMessage(content: message))
        case .user:
            return ChatCompletion
                .user(
                    UserMessage(
                        content: UserTextContent(string: message)
                    )
                )
        case .assistant:
            return ChatCompletion
                .assistant(
                    AssistantMessage(content: message)
                )
        case .tool:
            return nil
        }
    }
}
