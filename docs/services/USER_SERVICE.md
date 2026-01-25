# User Service

The User Service manages user profile data and preferences.

## Overview

The User Service handles user profile creation, updates, and retrieval. It supports both remote (Firebase) and local persistence with a protocol-based architecture.

## Architecture

```
UserManager (Orchestration)
    ↓
UserServicesProtocol
    ↓
├── ProductionUserServices
│   ├── RemoteUserServiceProtocol (Firebase)
│   └── LocalUserServiceProtocol (FileManager)
└── MockUserServices (Testing)
```

## Files

| File | Path |
|------|------|
| `UserManager.swift` | `Services/User/UserManager.swift` |
| `UserManagerProtocol.swift` | `Services/User/UserManagerProtocol.swift` |
| `UserServicesProtocol.swift` | `Services/User/Services/UserServicesProtocol.swift` |
| `ProductionUserServices.swift` | `Services/User/Services/ProductionUserServices.swift` |
| `MockUserServices.swift` | `Services/User/Services/MockUserServices.swift` |

### Remote Services
| File | Path |
|------|------|
| `RemoteUserServiceProtocol.swift` | `Services/User/Services/RemoteService/RemoteUserServiceProtocol.swift` |
| `FirebaseUserService.swift` | `Services/User/Services/RemoteService/FirebaseUserService.swift` |
| `MockUserService.swift` | `Services/User/Services/RemoteService/MockUserService.swift` |

### Local Services
| File | Path |
|------|------|
| `LocalUserServiceProtocol.swift` | `Services/User/Services/LocalService/LocalUserServiceProtocol.swift` |
| `FileManagerUserPersistence.swift` | `Services/User/Services/LocalService/FileManagerUserPersistence.swift` |
| `MockUserPersistence.swift` | `Services/User/Services/LocalService/MockUserPersistence.swift` |

### Models
| File | Path |
|------|------|
| `UserModel.swift` | `Services/User/Models/UserModel.swift` |

## Protocol Definition

### UserManagerProtocol
```swift
protocol UserManagerProtocol {
    var currentUser: UserModel? { get }

    func createUser(auth: UserAuthInfo, creationVersion: String?) async throws
    func getUser(userId: String) async throws -> UserModel?
    func updateUser(_ user: UserModel) async throws
    func deleteUser(userId: String) async throws
    func markOnboardingComplete() async throws
    func updateProfileColor(hex: String) async throws
}
```

## Usage

### Resolving from Container
```swift
let userManager = container.resolve(UserManager.self)
```

### Get Current User
```swift
if let user = userManager.currentUser {
    print("User: \(user.userId)")
    print("Email: \(user.email ?? "No email")")
    print("Onboarding complete: \(user.didCompleteOnboarding ?? false)")
}
```

### Create User
```swift
try await userManager.createUser(
    auth: authInfo,
    creationVersion: "1.0.0"
)
```

### Update Profile Color
```swift
try await userManager.updateProfileColor(hex: "#7DCEA0")
```

### Mark Onboarding Complete
```swift
try await userManager.markOnboardingComplete()
```

## Data Model

### UserModel
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

    var profileColorCalculated: Color {
        guard let profileColorHex else { return .accent }
        return Color(hex: profileColorHex)
    }
}
```

### Coding Keys
```swift
enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case email
    case isAnonymous = "is_anonymous"
    case creationDate = "creation_date"
    case creationVersion = "creation_version"
    case lastSignInDate = "last_sign_in_date"
    case didCompleteOnboarding = "did_complete_onboarding"
    case profileColorHex = "profile_color_hex"
}
```

## Build Configuration

### Development (.dev)
```swift
userManager = UserManager(
    services: ProductionUserServices(),
    logManager: logManager
)
```

### Production (.prod)
```swift
userManager = UserManager(
    services: ProductionUserServices(),
    logManager: logManager
)
```

### Mock (.mock)
```swift
userManager = UserManager(
    services: MockUserServices(
        currentUser: isSignedIn ? .mock : nil
    ),
    logManager: logManager
)
```

## Data Persistence

### Remote (Firebase Firestore)
- Primary data store
- Real-time sync
- Cross-device access

### Local (FileManager)
- Offline cache
- Fast access
- Fallback when offline

### Sync Strategy
1. Fetch from remote on app launch
2. Cache locally for offline access
3. Update remote on changes
4. Sync local cache after remote update

## Analytics Events

The UserManager logs important events:

| Event | Description |
|-------|-------------|
| `user_created` | New user account created |
| `user_updated` | User profile updated |
| `onboarding_completed` | User finished onboarding |
| `profile_color_changed` | User changed profile color |

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| User not found | User doesn't exist | Create new user |
| Update failed | Failed to save changes | Retry operation |
| Network error | Connection failed | Use cached data |

## Related Documentation

- [Auth Service](./AUTH_SERVICE.md)
- [Profile Feature](../features/PROFILE.md)
- [Data Models](../DATA_MODELS.md)
