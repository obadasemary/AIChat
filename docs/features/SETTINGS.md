# Settings Feature

The Settings feature provides app configuration and account management options.

## Overview

The Settings module allows users to manage their account, configure app preferences, access developer settings, and sign out.

## Architecture

```
SettingsView
    ↓
SettingsViewModel
    ↓
SettingsUseCase
    ↓
├── AuthManager (sign out)
├── UserManager (user data)
├── PurchaseManager (subscription)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `SettingsView.swift` | SwiftUI view for settings |
| `SettingsViewModel.swift` | View state management |
| `SettingsUseCase.swift` | Business logic |
| `SettingsBuilder.swift` | Dependency injection |
| `SettingsRouter.swift` | Navigation handling |

## Key Features

### Account Settings
- View account information
- Sign out functionality
- Delete account option
- Subscription management

### App Settings
- Theme selection (Light/Dark/System)
- Notification preferences
- Privacy settings

### Developer Settings (Debug only)
- A/B test overrides
- Feature flags
- Debug information
- Mock data toggles

### Navigation Links
- About screen
- Privacy policy
- Terms of service
- Contact support

## Usage

### Building the Settings View

```swift
@Environment(SettingsBuilder.self) var settingsBuilder

// Display settings
settingsBuilder.buildSettingsView()
```

### Sign Out

```swift
// In SettingsUseCase
func signOut() async throws {
    try authManager.signOut()
    // Clear local data
    // Navigate to welcome screen
}
```

## Settings Sections

### Profile Section
- Profile picture and name
- Tap to edit profile
- Profile color indicator

### Subscription Section
- Current plan display
- Upgrade/manage subscription
- Restore purchases

### Preferences Section
- Appearance (theme)
- Notifications
- Language

### Support Section
- Help center
- Contact us
- Report a bug

### Legal Section
- Privacy policy
- Terms of service
- Open source licenses

### Account Section
- Sign out
- Delete account

## Theme Support

```swift
enum ColorSchemePreference: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
```

## Dependencies

- **AuthManager**: Authentication operations
- **UserManager**: User preferences
- **PurchaseManager**: Subscription info
- **LogManager**: Analytics tracking

## Error Handling

| Error | Handling |
|-------|----------|
| Sign out failed | Show error alert, allow retry |
| Delete account failed | Show confirmation, then error if fails |
| Network error | Indicate offline mode |

## Related Documentation

- [Profile Feature](./PROFILE.md)
- [Dev Settings Feature](./DEV_SETTINGS.md)
- [Auth Service](../services/AUTH_SERVICE.md)
