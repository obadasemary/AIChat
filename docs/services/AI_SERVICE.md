# AI Service

The AI Service provides integration with OpenAI for text and image generation.

## Overview

The AI Service enables AI-powered conversations and avatar image generation through OpenAI's API. It follows the protocol-oriented design with production and mock implementations.

## Architecture

```
AIManager (Orchestration)
    ↓
AIServiceProtocol
    ↓
├── OpenAIServer (Production)
└── MockAIServer (Testing)
```

## Files

| File | Path |
|------|------|
| `AIManager.swift` | `Services/AI/AIManager.swift` |
| `AIManagerProtocol.swift` | `Services/AI/AIManagerProtocol.swift` |
| `AIServiceProtocol.swift` | `Services/AI/Services/AIServiceProtocol.swift` |
| `OpenAIServer.swift` | `Services/AI/Services/OpenAIServer.swift` |
| `MockAIServer.swift` | `Services/AI/Services/MockAIServer.swift` |

## Protocol Definition

### AIManagerProtocol
```swift
protocol AIManagerProtocol {
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
    func generateImage(input: String) async throws -> UIImage
}
```

### AIServiceProtocol
```swift
protocol AIServiceProtocol {
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
    func generateImage(input: String) async throws -> UIImage
}
```

## Usage

### Resolving from Container
```swift
let aiManager = container.resolve(AIManager.self)
```

### Text Generation
```swift
// Build chat history
let chats: [AIChatModel] = [
    AIChatModel(role: .system, message: "You are a helpful assistant."),
    AIChatModel(role: .user, message: "Hello!")
]

// Generate response
let response = try await aiManager.generateText(chats: chats)
print(response.message) // AI response text
```

### Image Generation
```swift
// Generate avatar image
let prompt = "A friendly robot smiling in a park"
let image = try await aiManager.generateImage(input: prompt)
```

## Data Models

### AIChatModel
```swift
struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String
}
```

### AIChatRole
```swift
enum AIChatRole: String, Codable {
    case system
    case user
    case assistant
}
```

## OpenAI Integration

### Configuration
The OpenAI API key is configured via:
1. Environment variable: `OPENAI_API_KEY`
2. Config.plist: `OpenAIAPIKey`

### API Endpoints Used
- **Chat Completions**: `/v1/chat/completions`
- **Image Generation**: `/v1/images/generations`

### Request Example
```swift
// Chat completion request
struct ChatCompletionRequest: Encodable {
    let model: String = "gpt-4"
    let messages: [ChatMessage]
    let temperature: Double = 0.7
}

struct ChatMessage: Encodable {
    let role: String
    let content: String
}
```

## Build Configuration

### Development (.dev)
```swift
aiManager = AIManager(service: OpenAIServer())
```

### Production (.prod)
```swift
aiManager = AIManager(service: OpenAIServer())
```

### Mock (.mock)
```swift
aiManager = AIManager(service: MockAIServer())
```

## Mock Service

The `MockAIServer` provides deterministic responses for testing:

```swift
class MockAIServer: AIServiceProtocol {
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        // Return mock response
        return AIChatModel(
            role: .assistant,
            message: "This is a mock response."
        )
    }

    func generateImage(input: String) async throws -> UIImage {
        // Return placeholder image
        return UIImage(systemName: "photo")!
    }
}
```

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Invalid API key | API key missing or invalid | Check configuration |
| Rate limited | Too many requests | Implement backoff |
| Network error | Connection failed | Retry with exponential backoff |
| Invalid response | Unexpected API response | Log and show error |

## Best Practices

1. **Always use async/await** for AI operations
2. **Handle errors gracefully** with user feedback
3. **Use system prompts** to guide AI behavior
4. **Limit message history** to manage token usage
5. **Cache responses** where appropriate

## Related Documentation

- [Chat Feature](../features/CHAT.md)
- [Create Avatar Feature](../features/CREATE_AVATAR.md)
- [Data Models](../DATA_MODELS.md)
