# Profile Feature

The Profile feature manages user profile display and customization.

## Overview

The Profile module displays user information including avatar, name, email, and profile color. It integrates with the Settings feature for profile editing.

## Architecture

```
ProfileView
    ↓
ProfileViewModel
    ↓
ProfileUseCase / ProfileInteractor
    ↓
├── UserManager (user data)
├── AvatarManager (avatar data)
├── AuthManager (auth info)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `ProfileView.swift` | SwiftUI view for profile display |
| `ProfileViewModel.swift` | View state management |
| `ProfileUseCase.swift` | Business logic |
| `ProfileBuilder.swift` | Dependency injection |
| `ProfileRouter.swift` | Navigation handling |
| `ProfileInteractor.swift` | Interactor protocol |
| `ProdProfileInteractor.swift` | Production implementation |

## Key Features

### Profile Display
- User avatar image
- Display name
- Email address
- Profile color theme
- Account creation date

### Profile Customization
- Change profile color
- Update display name
- Navigate to avatar creation
- Account settings access

### Avatar Integration
- Display current avatar
- Quick access to avatar creation
- Recent avatars display

## Usage

### Building the Profile View

```swift
@Environment(ProfileBuilder.self) var profileBuilder

// Display profile
profileBuilder.buildProfileView()
```

### Profile Modal

```swift
// Show profile in modal (used in chat)
router.showProfileModal(avatar: avatar) {
    // On dismiss callback
}
```

## Profile Color

Users can customize their profile color:

```swift
struct UserModel {
    let profileColorHex: String?

    var profileColorCalculated: Color {
        guard let profileColorHex else { return .accent }
        return Color(hex: profileColorHex)
    }
}
```

Available colors are defined in the onboarding color selection screen.

## Data Flow

1. View appears, triggers user data fetch
2. UserManager provides current user model
3. AvatarManager provides user's avatars
4. Display combined profile information
5. User interactions update via UseCase
6. Changes persisted to Firebase

## Dependencies

- **UserManager**: User profile data
- **AvatarManager**: Avatar retrieval
- **AuthManager**: Authentication info
- **LogManager**: Analytics tracking

## Related Documentation

- [Settings Feature](./SETTINGS.md)
- [Create Avatar Feature](./CREATE_AVATAR.md)
- [User Service](../services/USER_SERVICE.md)
