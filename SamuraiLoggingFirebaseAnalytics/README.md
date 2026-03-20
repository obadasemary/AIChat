# SamuraiLoggingFirebaseAnalytics

A `SamuraiLogging` service adapter that routes events to **Firebase Analytics**.

## Requirements

- iOS 17+ / macOS 14+
- Swift 6+
- [SamuraiLogging](../SamuraiLogging)
- Firebase iOS SDK 11.x

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(path: "../SamuraiLogging"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", "11.0.0"..<"12.0.0")
]
```

## Setup

Ensure Firebase is configured in your app before using this service (typically in `AppDelegate` or the app entry point):

```swift
import FirebaseCore
FirebaseApp.configure()
```

Then register `FirebaseAnalyticsService` with your `LogManager`:

```swift
import SamuraiLogging
import SamuraiLoggingFirebaseAnalytics

let logManager = LogManager(services: [
    ConsoleService(),       // optional, for debug builds
    FirebaseAnalyticsService()
])
```

## Behaviour

### `identify`
Sets the Firebase user ID and stores `account_name` / `account_email` as user properties.

### `addUserProperties`
Only processes **high-priority** properties (`isHighPriority: true`). Keys are trimmed to 24 characters, values to 100 characters per Firebase limits.

### `trackEvent`
- Events with `type == .info` are **skipped** (info logs are not analytics).
- Event names are trimmed to 40 characters.
- Parameters are sanitised before dispatch:
  - `Date` values are converted to strings.
  - `Array` values are converted to strings (or dropped if not convertible).
  - Parameter keys are trimmed to 40 characters.
  - String values are trimmed to 100 characters.
  - At most **25 parameters** are forwarded (Firebase limit).

### `trackScreen`
Logs a `screen_view` event using `AnalyticsEventScreenView` with the event name as `screen_name`.

### `deleteUserProfile`
No-op — Firebase Analytics does not support profile deletion via the SDK.

## Firebase Limits Reference

| Item | Limit |
|------|-------|
| Event name length | 40 characters |
| Parameter key length | 40 characters |
| Parameter value length | 100 characters |
| Parameters per event | 25 |
| User property key length | 24 characters |
| User property value length | 100 characters |

These limits are enforced automatically by `FirebaseAnalyticsService`.
