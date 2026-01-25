# Chats Feature

The Chats feature displays a list of all user conversations.

## Overview

The Chats module shows users their conversation history with various AI avatars, allowing them to continue previous conversations or start new ones.

## Architecture

```
ChatsView
    ↓
ChatsViewModel
    ↓
ChatsUseCase
    ↓
├── ChatManager (chat list)
├── AvatarManager (avatar data)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `ChatsView.swift` | SwiftUI view for chat list |
| `ChatsViewModel.swift` | View state and chat list management |
| `ChatsUseCase.swift` | Business logic for listing chats |
| `ChatsBuilder.swift` | Dependency injection |
| `ChatsRouter.swift` | Navigation to individual chats |

### ChatRowCell Submodule

| File | Purpose |
|------|---------|
| `ChatRowCellBuilder.swift` | Row cell construction |
| `ChatRowCellViewModel.swift` | Individual row state |
| `ChatRowCellUseCase.swift` | Row-level business logic |
| `ChatRowCellDelegate.swift` | Row interaction delegate |

## Key Features

### Chat List Display
- Shows all user conversations
- Sorted by last activity
- Displays avatar image and name
- Shows last message preview
- Unread message indicators

### Navigation
- Tap to open conversation
- Swipe actions for quick operations
- Pull to refresh

### Real-time Updates
- Firebase listener for chat updates
- Automatic UI refresh on changes

## Usage

### Building the Chats View

```swift
@Environment(ChatsBuilder.self) var chatsBuilder

// Display chats list
chatsBuilder.buildChatsView()
```

### Chat Row Cell

```swift
@Environment(ChatRowCellBuilder.self) var rowBuilder

// Build individual chat row
rowBuilder.buildChatRowCell(
    chat: chat,
    avatar: avatar
)
```

## Data Flow

1. View appears, triggers chat list fetch
2. UseCase retrieves user's chats from ChatManager
3. For each chat, fetch associated avatar
4. Display sorted list with avatar info
5. Listen for real-time updates
6. User taps row to navigate to chat

## Dependencies

- **ChatManager**: Chat list retrieval
- **AvatarManager**: Avatar data for display
- **AuthManager**: Current user identification
- **LogManager**: Analytics tracking

## Related Documentation

- [Chat Feature](./CHAT.md)
- [Chat Service](../services/CHAT_SERVICE.md)
- [Avatar Service](../services/AVATAR_SERVICE.md)
