# Chat Feature

The Chat feature provides AI-powered conversations using OpenAI's language models.

## Overview

The Chat module enables users to have real-time conversations with AI avatars. It supports message streaming, conversation history, and premium gating.

## Architecture

```
ChatView
    ↓
ChatViewModel
    ↓
ChatUseCase
    ↓
├── AIManager (text generation)
├── ChatManager (persistence)
├── AvatarManager (avatar data)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `ChatView.swift` | SwiftUI view for chat interface |
| `ChatViewModel.swift` | View state and presentation logic |
| `ChatUseCase.swift` | Business logic for chat operations |
| `ChatBuilder.swift` | Dependency injection and view construction |
| `ChatRouter.swift` | Navigation handling |
| `ChatDelegate.swift` | Delegate protocol for chat events |

## Key Features

### Real-time Messaging
- Send messages to AI avatars
- Receive AI-generated responses
- Typing indicator during response generation

### Message Management
- Message history persistence via Firebase
- Mark messages as seen
- Scroll to latest messages

### Premium Gating
- Free users limited to 3 messages per chat
- Paywall displayed when limit reached
- Premium users have unlimited access

### Chat Settings
- Report inappropriate content
- Delete chat conversations
- View avatar profile

## Usage

### Building the Chat View

```swift
@Environment(ChatBuilder.self) var chatBuilder

// Navigate to chat with avatar
chatBuilder.buildChatView(avatarId: avatar.id)
```

### ViewModel Events

The ChatViewModel tracks comprehensive analytics:

| Event | Description |
|-------|-------------|
| `loadAvatarStart/Success/Fail` | Avatar loading lifecycle |
| `loadChatStart/Success/Fail` | Chat loading lifecycle |
| `sendMessageStart/Sent/Response` | Message sending lifecycle |
| `reportChatStart/Success/Fail` | Report functionality |
| `deleteChatStart/Success/Fail` | Delete functionality |

## Data Flow

1. User enters message in text field
2. ViewModel validates message
3. Check premium status (show paywall if needed)
4. Create or retrieve existing chat
5. Send user message to Firebase
6. Generate AI response via OpenAI
7. Store AI response in Firebase
8. Update UI with new messages

## Dependencies

- **AIManager**: Text generation via OpenAI
- **ChatManager**: Chat and message persistence
- **AvatarManager**: Avatar data retrieval
- **AuthManager**: User authentication
- **PurchaseManager**: Premium status check
- **LogManager**: Event tracking

## Error Handling

| Error | Handling |
|-------|----------|
| Invalid message | Show validation error alert |
| Chat creation failed | Display error alert |
| AI generation failed | Show error, allow retry |
| Network error | Display connectivity message |

## Related Documentation

- [AI Service](../services/AI_SERVICE.md)
- [Chat Service](../services/CHAT_SERVICE.md)
- [Data Models](../DATA_MODELS.md)
