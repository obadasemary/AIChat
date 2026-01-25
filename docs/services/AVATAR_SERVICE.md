# Avatar Service

The Avatar Service manages AI avatar creation, storage, and retrieval.

## Overview

The Avatar Service handles avatar CRUD operations with support for remote (Firebase) and local (SwiftData) persistence.

## Architecture

```
AvatarManager (Orchestration)
    ↓
├── RemoteAvatarServiceProtocol
│   ├── FirebaseAvatarService (Production)
│   └── MockAvatarService (Testing)
└── LocalAvatarServicePersistenceProtocol
    ├── SwiftDataLocalAvatarServicePersistence (Production)
    └── MockLocalAvatarServicePersistence (Testing)
```

## Files

| File | Path |
|------|------|
| `AvatarManager.swift` | `Services/Avatar/AvatarManager.swift` |
| `AvatarManagerProtocol.swift` | `Services/Avatar/AvatarManagerProtocol.swift` |

### Remote Services
| File | Path |
|------|------|
| `RemoteAvatarServiceProtocol.swift` | `Services/Avatar/Services/RemoteService/RemoteAvatarServiceProtocol.swift` |
| `FirebaseAvatarService.swift` | `Services/Avatar/Services/RemoteService/FirebaseAvatarService.swift` |
| `MockAvatarService.swift` | `Services/Avatar/Services/RemoteService/MockAvatarService.swift` |

### Local Services
| File | Path |
|------|------|
| `LocalAvatarServicePersistenceProtocol.swift` | `Services/Avatar/Services/LocalService/LocalAvatarServicePersistenceProtocol.swift` |
| `SwiftDataLocalAvatarServicePersistence.swift` | `Services/Avatar/Services/LocalService/SwiftDataLocalAvatarServicePersistence.swift` |
| `MockLocalAvatarServicePersistence.swift` | `Services/Avatar/Services/LocalService/MockLocalAvatarServicePersistence.swift` |

### Models
| File | Path |
|------|------|
| `AvatarModel.swift` | `Services/Avatar/Models/AvatarModel.swift` |
| `AvatarEntity.swift` | `Services/Avatar/Models/AvatarEntity.swift` |
| `AvatarAttributes.swift` | `Services/Avatar/Models/AvatarAttributes.swift` |

## Protocol Definition

### AvatarManagerProtocol
```swift
protocol AvatarManagerProtocol {
    func getAvatar(id: String) async throws -> AvatarModel?
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func getAvatarsForCategory(_ category: CharacterOption) async throws -> [AvatarModel]
    func getUserAvatars(userId: String) async throws -> [AvatarModel]

    func createAvatar(_ avatar: AvatarModel) async throws
    func updateAvatar(_ avatar: AvatarModel) async throws
    func deleteAvatar(id: String) async throws

    func uploadAvatarImage(_ image: UIImage) async throws -> String
    func addRecentAvatar(_ avatar: AvatarModel) async throws
    func getRecentAvatars() async throws -> [AvatarModel]
}
```

## Usage

### Resolving from Container
```swift
let avatarManager = container.resolve(AvatarManager.self)
```

### Get Avatar
```swift
let avatar = try await avatarManager.getAvatar(id: avatarId)
```

### Create Avatar
```swift
let avatar = AvatarModel.newAvatar(
    name: "Buddy",
    option: .robot,
    action: .smiling,
    location: .park,
    authorId: userId
)
try await avatarManager.createAvatar(avatar)
```

### Get Featured Avatars
```swift
let featuredAvatars = try await avatarManager.getFeaturedAvatars()
```

### Upload Avatar Image
```swift
let imageUrl = try await avatarManager.uploadAvatarImage(generatedImage)
```

## Data Models

### AvatarModel
```swift
struct AvatarModel: Hashable, Codable {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorId: String?
    let dateCreated: Date?
    let clickCount: Int?

    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }
}
```

### Character Options
```swift
enum CharacterOption: String, CaseIterable, Codable {
    case man, woman
    case dog, cat
    case alien, robot
    // ...
}

enum CharacterAction: String, CaseIterable, Codable {
    case smiling, eating, drinking
    case shopping, studying, relaxing
    // ...
}

enum CharacterLocation: String, CaseIterable, Codable {
    case park, forest, beach
    case mall, museum, home
    // ...
}
```

### AvatarEntity (SwiftData)
```swift
@Model
final class AvatarEntity {
    @Attribute(.unique) var avatarId: String
    var name: String?
    var characterOption: String?
    var characterAction: String?
    var characterLocation: String?
    var profileImageName: String?
    var authorId: String?
    var dateCreated: Date?
    var clickCount: Int?
}
```

## Build Configuration

### Development (.dev)
```swift
avatarManager = AvatarManager(
    remoteService: FirebaseAvatarService(
        firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
    ),
    localStorage: SwiftDataLocalAvatarServicePersistence()
)
```

### Production (.prod)
```swift
avatarManager = AvatarManager(
    remoteService: FirebaseAvatarService(
        firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
    ),
    localStorage: SwiftDataLocalAvatarServicePersistence()
)
```

### Mock (.mock)
```swift
avatarManager = AvatarManager(
    remoteService: MockAvatarService(),
    localStorage: MockLocalAvatarServicePersistence()
)
```

## Avatar Description Builder

Generates descriptions for AI image generation:

```swift
struct AvatarDescriptionBuilder {
    let avatar: AvatarModel

    var characterDescription: String {
        var parts: [String] = []

        if let option = avatar.characterOption {
            parts.append("A friendly \(option.rawValue)")
        }
        if let action = avatar.characterAction {
            parts.append(action.rawValue)
        }
        if let location = avatar.characterLocation {
            parts.append("in a \(location.rawValue)")
        }

        return parts.joined(separator: " ")
        // Example: "A friendly robot smiling in a park"
    }
}
```

## Firebase Structure

```
avatars/
  {avatarId}/
    - avatar_id: String
    - name: String
    - character_option: String
    - character_action: String
    - character_location: String
    - profile_image_name: String
    - author_id: String
    - date_created: Timestamp
    - click_count: Int
```

## Image Upload

Avatar images are uploaded to Firebase Storage:

```swift
// FirebaseImageUploadService
func uploadImage(_ image: UIImage, path: String) async throws -> String {
    let data = image.jpegData(compressionQuality: 0.8)!
    let ref = Storage.storage().reference().child(path)
    _ = try await ref.putDataAsync(data)
    return try await ref.downloadURL().absoluteString
}
```

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Avatar not found | Avatar doesn't exist | Show error message |
| Upload failed | Image upload failed | Retry operation |
| Create failed | Failed to save avatar | Show error, allow retry |

## Related Documentation

- [Create Avatar Feature](../features/CREATE_AVATAR.md)
- [Explore Feature](../features/EXPLORE.md)
- [AI Service](./AI_SERVICE.md)
