# Create Avatar Feature

The Create Avatar feature allows users to design and create custom AI avatars.

## Overview

The Create Avatar module provides a step-by-step interface for creating personalized AI avatars with customizable attributes including character type, action, and location.

## Architecture

```
CreateAvatarView
    ↓
CreateAvatarViewModel
    ↓
CreateAvatarUseCase
    ↓
├── AvatarManager (creation & storage)
├── AIManager (image generation)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `CreateAvatarView.swift` | SwiftUI view for avatar creation |
| `CreateAvatarViewModel.swift` | View state and creation flow |
| `CreateAvatarUseCase.swift` | Business logic |
| `CreateAvatarBuilder.swift` | Dependency injection |
| `CreateAvatarRouter.swift` | Navigation handling |

## Key Features

### Avatar Customization
- Name input
- Character type selection
- Action selection
- Location selection
- AI-generated profile image

### Character Options
```swift
enum CharacterOption: String, CaseIterable {
    case man, woman
    case dog, cat
    case alien, robot
    // ... more options
}
```

### Character Actions
```swift
enum CharacterAction: String, CaseIterable {
    case smiling, eating, drinking
    case shopping, studying, relaxing
    case dancing, jumping, singing
    // ... more actions
}
```

### Character Locations
```swift
enum CharacterLocation: String, CaseIterable {
    case park, forest, beach
    case mall, museum, home
    case mountain, city, space
    // ... more locations
}
```

## Usage

### Building the Create Avatar View

```swift
@Environment(CreateAvatarBuilder.self) var createAvatarBuilder

// Display avatar creation
createAvatarBuilder.buildCreateAvatarView()
```

### Creating an Avatar

```swift
// In CreateAvatarUseCase
func createAvatar(
    name: String,
    option: CharacterOption,
    action: CharacterAction,
    location: CharacterLocation
) async throws -> AvatarModel {
    // 1. Create avatar model
    let avatar = AvatarModel.newAvatar(
        name: name,
        option: option,
        action: action,
        location: location,
        authorId: authManager.currentUserId
    )

    // 2. Generate AI image
    let image = try await aiManager.generateImage(
        input: avatar.characterDescription
    )

    // 3. Upload to storage
    let imageUrl = try await avatarManager.uploadImage(image)

    // 4. Save avatar
    try await avatarManager.saveAvatar(avatar, imageUrl: imageUrl)

    return avatar
}
```

## Creation Flow

1. **Name Entry**: User enters avatar name
2. **Character Selection**: Choose character type
3. **Action Selection**: Choose what character is doing
4. **Location Selection**: Choose background setting
5. **Preview**: Review selections
6. **Generation**: AI generates profile image
7. **Confirmation**: Save and start chatting

## AI Image Generation

Avatar images are generated using OpenAI's image generation:

```swift
// Build description from attributes
let description = AvatarDescriptionBuilder(avatar: avatar).characterDescription
// Example: "A friendly alien smiling in a park"

// Generate image
let image = try await aiManager.generateImage(input: description)
```

## Data Model

### AvatarModel
```swift
struct AvatarModel {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorId: String?
    let dateCreated: Date?
    let clickCount: Int?
}
```

## Dependencies

- **AvatarManager**: Avatar creation and storage
- **AIManager**: Image generation
- **AuthManager**: User identification
- **LogManager**: Analytics tracking

## Error Handling

| Error | Handling |
|-------|----------|
| Name validation failed | Show validation message |
| Image generation failed | Allow retry with different description |
| Upload failed | Show error, allow retry |
| Save failed | Show error, maintain state |

## Related Documentation

- [Explore Feature](./EXPLORE.md)
- [Avatar Service](../services/AVATAR_SERVICE.md)
- [AI Service](../services/AI_SERVICE.md)
