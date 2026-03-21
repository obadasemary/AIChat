# SamuraiLoggingMixpanel

A `SamuraiLogging` service adapter that routes events to **Mixpanel**.

## Requirements

- iOS 17+ / macOS 14+
- Swift 6+
- [SamuraiLogging](../SamuraiLogging)
- Mixpanel Swift SDK 4.x

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(path: "../SamuraiLogging"),
    .package(url: "https://github.com/mixpanel/mixpanel-swift.git", "4.0.0"..<"5.0.0")
]
```

## Setup

Register `MixpanelService` with your `LogManager`, passing your Mixpanel project token:

```swift
import SamuraiLogging
import SamuraiLoggingMixpanel

let logManager = LogManager(services: [
    ConsoleService(),       // optional, for debug builds
    MixpanelService(token: "YOUR_MIXPANEL_TOKEN")
])
```

Pass `loggingEnabled: true` during development to enable Mixpanel's internal logging:

```swift
MixpanelService(token: "YOUR_MIXPANEL_TOKEN", loggingEnabled: true)
```

## Behaviour

### `identify`
Calls `identify(distinctId:)` and sets `$name` / `$email` on the Mixpanel People profile.

### `addUserProperties`
Sets properties on the People profile. Only values that conform to `MixpanelType` are forwarded. Keys are trimmed to 255 characters.

### `trackEvent`
- Events with `type == .info` are **skipped**.
- Parameters are filtered to `MixpanelType`-compatible values; keys are trimmed to 255 characters.

### `trackScreen`
Delegates to `trackEvent`.

### `deleteUserProfile`
Calls `deleteUser()` on the Mixpanel People API.

## Mixpanel Limits Reference

| Item | Limit |
|------|-------|
| Property key length | 255 characters |
| Property value | Must conform to `MixpanelType` |
