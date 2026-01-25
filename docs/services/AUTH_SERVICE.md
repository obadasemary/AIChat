# Auth Service

The Auth Service manages user authentication using Firebase Authentication.

## Overview

The Auth Service handles user sign-in, sign-out, account creation, and authentication state management through Firebase Authentication.

## Architecture

```
AuthManager (Orchestration)
    ↓
AuthServiceProtocol
    ↓
├── FirebaseAuthService (Production)
└── MockAuthService (Testing)
```

## Files

| File | Path |
|------|------|
| `AuthManager.swift` | `Services/Auth/AuthManager.swift` |
| `AuthManagerProtocol.swift` | `Services/Auth/AuthManagerProtocol.swift` |
| `AuthServiceProtocol.swift` | `Services/Auth/Services/AuthServiceProtocol.swift` |
| `FirebaseAuthService.swift` | `Services/Auth/Services/FirebaseAuthService.swift` |
| `MockAuthService.swift` | `Services/Auth/Services/MockAuthService.swift` |

### Models
| File | Path |
|------|------|
| `UserAuthInfo.swift` | `Services/Auth/Models/UserAuthInfo.swift` |
| `UserAuthInfo+Firebase.swift` | `Services/Auth/Models/UserAuthInfo+Firebase.swift` |

## Protocol Definition

### AuthManagerProtocol
```swift
protocol AuthManagerProtocol {
    var auth: UserAuthInfo? { get }

    func signInAnonymously() async throws -> UserAuthInfo
    func signInWithApple() async throws -> UserAuthInfo
    func signInWithGoogle(result: GoogleSignInResult) async throws -> UserAuthInfo
    func signOut() throws
    func deleteAccount() async throws
    func getAuthId() throws -> String
}
```

## Usage

### Resolving from Container
```swift
let authManager = container.resolve(AuthManager.self)
```

### Sign In Anonymously
```swift
let user = try await authManager.signInAnonymously()
print("Signed in as: \(user.uid)")
```

### Sign In with Apple
```swift
let user = try await authManager.signInWithApple()
print("Signed in with Apple: \(user.email ?? "No email")")
```

### Sign Out
```swift
try authManager.signOut()
```

### Get Current User
```swift
if let currentUser = authManager.auth {
    print("User ID: \(currentUser.uid)")
}
```

## Data Models

### UserAuthInfo
```swift
struct UserAuthInfo {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?
}
```

### Firebase Extension
```swift
extension UserAuthInfo {
    init(firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email
        self.isAnonymous = firebaseUser.isAnonymous
        self.creationDate = firebaseUser.metadata.creationDate
        self.lastSignInDate = firebaseUser.metadata.lastSignInDate
    }
}
```

## Authentication Methods

### Anonymous Sign-In
- No credentials required
- Creates temporary account
- Can be upgraded to full account later

### Sign in with Apple
- Uses ASAuthorizationController
- Retrieves Apple ID credentials
- Supports email hiding

### Sign in with Google
- Uses Google Sign-In SDK
- Retrieves Google credentials
- Links with Firebase

## Build Configuration

### Development (.dev)
```swift
authManager = AuthManager(
    service: FirebaseAuthService(),
    logManager: logManager
)
```

### Production (.prod)
```swift
authManager = AuthManager(
    service: FirebaseAuthService(),
    logManager: logManager
)
```

### Mock (.mock)
```swift
authManager = AuthManager(
    service: MockAuthService(
        currentUser: isSignedIn ? .mock() : nil
    ),
    logManager: logManager
)
```

## Mock Service

The `MockAuthService` simulates authentication for testing:

```swift
class MockAuthService: AuthServiceProtocol {
    private var currentUser: UserAuthInfo?

    init(currentUser: UserAuthInfo? = nil) {
        self.currentUser = currentUser
    }

    func signInAnonymously() async throws -> UserAuthInfo {
        let user = UserAuthInfo.mock()
        currentUser = user
        return user
    }

    // ... other methods
}
```

## Firebase Configuration

Firebase is configured based on build configuration:

```swift
func configureFirebase() {
    switch self {
    case .mock:
        break // No Firebase in mock
    case .dev:
        // Uses GoogleService-Info-Dev.plist
    case .prod:
        // Uses GoogleService-Info-Prod.plist
    }
}
```

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Not authenticated | No current user | Redirect to sign-in |
| Sign-in failed | Authentication failed | Show error, allow retry |
| Account deleted | Account no longer exists | Clear local data |
| Network error | Connection failed | Show offline indicator |

## Security Considerations

1. **Never store credentials locally**
2. **Use Firebase security rules**
3. **Validate user on sensitive operations**
4. **Handle session expiration gracefully**
5. **Log security-related events**

## Related Documentation

- [User Service](./USER_SERVICE.md)
- [Settings Feature](../features/SETTINGS.md)
- [Onboarding Feature](../features/ONBOARDING.md)
