# Chat Service

The Chat Service manages chat conversations and message persistence.

## Overview

The Chat Service handles chat creation, message storage, real-time message streaming, and chat management through Firebase Firestore.

## Architecture

```
ChatManager (Orchestration)
    ↓
ChatServiceProtocol
    ↓
├── FirebaseChatService (Production)
└── MockChatService (Testing)
```

## Files

| File | Path |
|------|------|
| `ChatManager.swift` | `Services/Chat/ChatManager.swift` |
| `ChatManagerProtocol.swift` | `Services/Chat/ChatManagerProtocol.swift` |
| `ChatServiceProtocol.swift` | `Services/Chat/Services/ChatServiceProtocol.swift` |
| `FirebaseChatService.swift` | `Services/Chat/Services/FirebaseChatService.swift` |
| `MockChatService.swift` | `Services/Chat/Services/MockChatService.swift` |

### Models
| File | Path |
|------|------|
| `ChatModel.swift` | `Services/Chat/Models/ChatModel.swift` |
| `ChatMessageModel.swift` | `Services/Chat/Models/ChatMessageModel.swift` |
| `AIChatModel.swift` | `Services/Chat/Models/AIChatModel.swift` |
| `AIChatRole.swift` | `Services/Chat/Models/AIChatRole.swift` |
| `ChatReportModel.swift` | `Services/Chat/Models/ChatReportModel.swift` |

## Protocol Definition

### ChatManagerProtocol
```swift
protocol ChatManagerProtocol {
    func createChat(_ chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getChatsForUser(userId: String) async throws -> [ChatModel]
    func deleteChat(chatId: String) async throws

    func addMessage(_ message: ChatMessageModel) async throws
    func streamMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func markMessageAsSeen(chatId: String, messageId: String, userId: String) async throws

    func reportChat(chatId: String, userId: String) async throws
}
```

## Usage

### Resolving from Container
```swift
let chatManager = container.resolve(ChatManager.self)
```

### Create New Chat
```swift
let chat = ChatModel.new(userId: userId, avatarId: avatarId)
try await chatManager.createChat(chat)
```

### Get Existing Chat
```swift
let chat = try await chatManager.getChat(
    userId: userId,
    avatarId: avatarId
)
```

### Send Message
```swift
let message = ChatMessageModel.newUserMessage(
    chatId: chat.id,
    userId: userId,
    message: AIChatModel(role: .user, message: "Hello!")
)
try await chatManager.addMessage(message)
```

### Stream Messages (Real-time)
```swift
for try await messages in chatManager.streamMessages(chatId: chat.id) {
    // Update UI with new messages
    self.chatMessages = messages
}
```

## Data Models

### ChatModel
```swift
struct ChatModel: Identifiable, Codable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date

    static func chatId(userId: String, avatarId: String) -> String {
        "\(userId)_\(avatarId)"
    }
}
```

### ChatMessageModel
```swift
struct ChatMessageModel: Identifiable, Codable {
    let id: String
    let chatId: String
    let authorId: String
    let content: AIChatModel
    let seenByIds: [String]
    let dateCreated: Date

    func hasBeenSeenBy(userId: String) -> Bool {
        seenByIds.contains(userId)
    }
}
```

### AIChatModel
```swift
struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String
}

enum AIChatRole: String, Codable {
    case system
    case user
    case assistant
}
```

## Firebase Structure

### Firestore Collections
```
chats/
  {chatId}/
    - userId: String
    - avatarId: String
    - dateCreated: Timestamp
    - dateModified: Timestamp
    messages/
      {messageId}/
        - chatId: String
        - authorId: String
        - content: Map
        - seenByIds: [String]
        - dateCreated: Timestamp

chat_reports/
  {reportId}/
    - chatId: String
    - userId: String
    - dateCreated: Timestamp
```

## Build Configuration

### Development (.dev)
```swift
chatManager = ChatManager(service: FirebaseChatService())
```

### Production (.prod)
```swift
chatManager = ChatManager(service: FirebaseChatService())
```

### Mock (.mock)
```swift
chatManager = ChatManager(service: MockChatService())
```

## Real-time Updates

The service uses Firestore snapshots for real-time message updates:

```swift
func streamMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
    AsyncThrowingStream { continuation in
        let listener = messagesCollection(chatId: chatId)
            .order(by: "date_created")
            .addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                let messages = snapshot?.documents.compactMap {
                    try? $0.data(as: ChatMessageModel.self)
                } ?? []
                continuation.yield(messages)
            }

        continuation.onTermination = { _ in
            listener.remove()
        }
    }
}
```

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Chat not found | Chat doesn't exist | Create new chat |
| Message failed | Failed to send message | Retry operation |
| Stream error | Real-time connection lost | Reconnect automatically |
| Report failed | Failed to submit report | Retry with feedback |

## Related Documentation

- [Chat Feature](../features/CHAT.md)
- [Chats Feature](../features/CHATS.md)
- [AI Service](./AI_SERVICE.md)
