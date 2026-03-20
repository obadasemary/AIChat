# SamuraiLoggingFirebaseCrashlytics

A `SamuraiLogging` service adapter that routes errors and warnings to **Firebase Crashlytics**.

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

Then register `FirebaseCrashlyticsService` with your `LogManager`:

```swift
import SamuraiLogging
import SamuraiLoggingFirebaseCrashlytics

let logManager = LogManager(services: [
    ConsoleService(),       // optional, for debug builds
    FirebaseCrashlyticsService()
])
```

## Behaviour

### `identify`
Sets the Crashlytics user ID and stores `account_name` / `account_email` as custom keys.

### `addUserProperties`
Only processes **high-priority** properties (`isHighPriority: true`). Each key-value pair is set as a Crashlytics custom value.

### `trackEvent`
- Events with `type == .info` or `type == .analytic` are **skipped**.
- Only `.warning` and `.severe` events are recorded as non-fatal errors via `record(error:userInfo:)`.
- The error domain is the event name; the error code is a stable hash of the event name.
- Event parameters are forwarded as the error's `userInfo`.

### `trackScreen`
Delegates to `trackEvent` — screen views are only recorded if they carry a `.warning` or `.severe` type.

### `deleteUserProfile`
Resets the Crashlytics user ID to `"new"` (soft delete, as Crashlytics does not support full profile deletion via the SDK).
