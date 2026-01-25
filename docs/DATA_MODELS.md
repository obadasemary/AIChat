# Data Models Documentation

Complete reference for all data models used in AIChat.

## Table of Contents

1. [User Models](#user-models)
2. [Chat Models](#chat-models)
3. [Avatar Models](#avatar-models)
4. [News Models](#news-models)
5. [Purchase Models](#purchase-models)
6. [Analytics Models](#analytics-models)

---

## User Models

### UserAuthInfo

Authentication information from Firebase Auth.

```swift
struct UserAuthInfo {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?
}
```

| Property | Type | Description |
|----------|------|-------------|
| `uid` | `String` | Unique user identifier from Firebase |
| `email` | `String?` | User's email (nil for anonymous users) |
| `isAnonymous` | `Bool` | Whether user signed in anonymously |
| `creationDate` | `Date?` | When account was created |
| `lastSignInDate` | `Date?` | Last sign-in timestamp |

### UserModel

Complete user profile stored in Firestore.

```swift
struct UserModel: Codable {
    let userId: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
}
```

| Property | Type | Description |
|----------|------|-------------|
| `userId` | `String` | Primary identifier (matches `uid`) |
| `email` | `String?` | User's email address |
| `isAnonymous` | `Bool` | Anonymous account flag |
| `creationDate` | `Date?` | Account creation date |
| `creationVersion` | `String?` | App version at creation |
| `lastSignInDate` | `Date?` | Most recent sign-in |
| `didCompleteOnboarding` | `Bool?` | Onboarding completion status |
| `profileColorHex` | `String?` | Selected profile color |

**Firestore Path**: `users/{userId}`

**Computed Properties**:
```swift
var profileColorCalculated: Color {
    guard let profileColorHex else { return .accent }
    return Color(hex: profileColorHex)
}
```

---

## Chat Models

### ChatModel

Represents a conversation between a user and an avatar.

```swift
struct ChatModel: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
}
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Composite key: `{userId}_{avatarId}` |
| `userId` | `String` | Owner of the chat |
| `avatarId` | `String` | Avatar participant |
| `dateCreated` | `Date` | Chat creation timestamp |
| `dateModified` | `Date` | Last activity timestamp |

**Firestore Path**: `chats/{chatId}`

**Factory Method**:
```swift
static func new(userId: String, avatarId: String) -> ChatModel
```

### ChatMessageModel

Individual message within a chat.

```swift
struct ChatMessageModel: Identifiable, Codable {
    let id: String
    let chatId: String
    let authorId: String
    let content: AIChatModel
    let seenByIds: [String]
    let dateCreated: Date
}
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique message identifier |
| `chatId` | `String` | Parent chat reference |
| `authorId` | `String` | User ID or Avatar ID |
| `content` | `AIChatModel` | Message content and role |
| `seenByIds` | `[String]` | Users who have seen message |
| `dateCreated` | `Date` | Message timestamp |

**Firestore Path**: `chats/{chatId}/messages/{messageId}`

**Utility Methods**:
```swift
func hasBeenSeenBy(userId: String) -> Bool
static func newUserMessage(chatId:, userId:, message:) -> ChatMessageModel
static func newAIMessage(chatId:, avatarId:, message:) -> ChatMessageModel
```

### AIChatModel

Message content for AI interactions.

```swift
struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String
}
```

### AIChatRole

```swift
enum AIChatRole: String, Codable {
    case system     // System instructions
    case user       // User messages
    case assistant  // AI responses
}
```

### ChatReportModel

Report for inappropriate content.

```swift
struct ChatReportModel: Codable {
    let chatId: String
    let userId: String
    let dateCreated: Date
}
```

**Firestore Path**: `chat_reports/{reportId}`

---

## Avatar Models

### AvatarModel

AI avatar character.

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
}
```

| Property | Type | Description |
|----------|------|-------------|
| `avatarId` | `String` | Unique identifier |
| `name` | `String?` | Display name |
| `characterOption` | `CharacterOption?` | Character type |
| `characterAction` | `CharacterAction?` | Current action |
| `characterLocation` | `CharacterLocation?` | Setting/location |
| `profileImageName` | `String?` | Firebase Storage path |
| `authorId` | `String?` | Creator's user ID |
| `dateCreated` | `Date?` | Creation timestamp |
| `clickCount` | `Int?` | Popularity metric |

**Firestore Path**: `avatars/{avatarId}`

**Computed Properties**:
```swift
var id: String { avatarId }
var characterDescription: String // For AI image generation
```

### CharacterOption

```swift
enum CharacterOption: String, CaseIterable, Codable {
    case man
    case woman
    case dog
    case cat
    case alien
    case robot
    // ... additional options
}
```

### CharacterAction

```swift
enum CharacterAction: String, CaseIterable, Codable {
    case smiling
    case eating
    case drinking
    case shopping
    case studying
    case relaxing
    case dancing
    case jumping
    case singing
    // ... additional actions
}
```

### CharacterLocation

```swift
enum CharacterLocation: String, CaseIterable, Codable {
    case park
    case forest
    case beach
    case mall
    case museum
    case home
    case mountain
    case city
    case space
    // ... additional locations
}
```

### AvatarEntity (SwiftData)

Local persistence model for avatars.

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

---

## News Models

### NewsArticle

News article from NewsAPI.

```swift
struct NewsArticle: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String?
    let content: String?
    let author: String?
    let source: NewsSource
    let url: String
    let imageUrl: String?
    let publishedAt: Date
    let category: String?
}
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | SHA256 hash of URL |
| `title` | `String` | Article headline |
| `description` | `String?` | Short summary |
| `content` | `String?` | Full article content |
| `author` | `String?` | Author name |
| `source` | `NewsSource` | Publisher information |
| `url` | `String` | Original article URL |
| `imageUrl` | `String?` | Featured image URL |
| `publishedAt` | `Date` | Publication date |
| `category` | `String?` | News category |

### NewsSource

```swift
struct NewsSource: Codable, Equatable {
    let id: String?
    let name: String
}
```

### BookmarkArticleEntity (SwiftData)

Locally bookmarked article.

```swift
@Model
final class BookmarkArticleEntity {
    @Attribute(.unique) var id: String
    var title: String
    var articleDescription: String?
    var content: String?
    var author: String?
    var sourceName: String
    var url: String
    var imageUrl: String?
    var publishedAt: Date
    var category: String?
    var bookmarkedAt: Date
}
```

---

## Purchase Models

### AnyProduct

Abstraction over StoreKit Product.

```swift
struct AnyProduct: Identifiable {
    let id: String
    let displayName: String
    let displayPrice: String
    let description: String
    let subscription: SubscriptionInfo?

    var isSubscription: Bool { subscription != nil }
}
```

### EntitlementOption

Available subscription products.

```swift
enum EntitlementOption: String, CaseIterable {
    case weekly = "com.aichat.premium.weekly"
    case monthly = "com.aichat.premium.monthly"
    case yearly = "com.aichat.premium.yearly"
    case lifetime = "com.aichat.premium.lifetime"
}
```

### PurchasedEntitlement

Active subscription/purchase.

```swift
struct PurchasedEntitlement {
    let productId: String
    let purchaseDate: Date
    let expirationDate: Date?
    let isActive: Bool
    let ownershipType: EntitlementOwnershipOption
}
```

### EntitlementOwnershipOption

```swift
enum EntitlementOwnershipOption: String {
    case purchased
    case familyShared
}
```

---

## Analytics Models

### LoggableEvent

Protocol for trackable events.

```swift
protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
```

### LogType

```swift
enum LogType {
    case analytic   // Standard analytics
    case warning    // Warning logs
    case severe     // Error logs + crash reporting
}
```

### Event Parameters

Models that support analytics include `eventParameters`:

```swift
extension UserModel {
    var eventParameters: [String: Any] {
        [
            "user_user_id": userId,
            "user_email": email,
            "user_is_anonymous": isAnonymous,
            // ...
        ].compactMapValues { $0 }
    }
}
```

---

## Model Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                        UserModel                             │
│                           │                                  │
│            ┌──────────────┼──────────────┐                  │
│            ▼              ▼              ▼                  │
│      AvatarModel     ChatModel    PurchasedEntitlement      │
│            │              │                                  │
│            │              ▼                                  │
│            │      ChatMessageModel                          │
│            │              │                                  │
│            └──────────────┤                                  │
│                           ▼                                  │
│                     AIChatModel                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      NewsArticle                             │
│                           │                                  │
│            ┌──────────────┴──────────────┐                  │
│            ▼                             ▼                  │
│       NewsSource              BookmarkArticleEntity         │
└─────────────────────────────────────────────────────────────┘
```

---

## Coding Keys Reference

All Firestore models use snake_case for document fields:

| Swift Property | Firestore Field |
|----------------|-----------------|
| `userId` | `user_id` |
| `avatarId` | `avatar_id` |
| `dateCreated` | `date_created` |
| `dateModified` | `date_modified` |
| `profileImageName` | `profile_image_name` |
| `characterOption` | `character_option` |
| `isAnonymous` | `is_anonymous` |
| `didCompleteOnboarding` | `did_complete_onboarding` |
| `profileColorHex` | `profile_color_hex` |
