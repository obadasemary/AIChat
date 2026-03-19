# SamuraiLogging

A lightweight, protocol-driven logging framework for iOS. Route analytics events, screen views, and user identification through multiple logging backends from a single unified API.

## Requirements

- iOS 17+
- Swift 6+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../SamuraiLogging")
]
```

Or in Xcode: **File → Add Package Dependencies** and point to the local path.

## Core Concepts

| Type | Role |
|------|------|
| `LogManagerProtocol` | The public interface consumed by app code |
| `LogManager` | Concrete implementation that fans out to multiple services |
| `LogServiceProtocol` | Interface each backend must implement |
| `LoggableEvent` | Protocol for typed, structured events |
| `AnyLoggableEvent` | Type-erased event for ad-hoc logging |
| `LogType` | Severity: `.info`, `.analytic`, `.warning`, `.severe` |

## Setup

1. Create one or more services that conform to `LogServiceProtocol`.
2. Pass them to `LogManager`.
3. Inject `LogManager` (or `LogManagerProtocol`) wherever logging is needed.

```swift
import SamuraiLogging

let logManager = LogManager(services: [
    ConsoleService()
    // add more services here
])
```

## Usage

### Identify a user

```swift
logManager.identify(userId: "abc123", name: "Jane", email: "jane@example.com")
```

### Track an event (ad-hoc)

```swift
logManager.trackEvent(
    eventName: "button_tapped",
    parameters: ["screen": "home", "button": "start"],
    type: .analytic
)
```

### Track a typed event

Define your events as types conforming to `LoggableEvent`:

```swift
enum AppEvent: LoggableEvent {
    case chatStarted(avatarId: String)

    var eventName: String {
        switch self {
        case .chatStarted: "chat_started"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .chatStarted(let id): ["avatar_id": id]
        }
    }

    var type: LogType { .analytic }
}

logManager.trackEvent(event: AppEvent.chatStarted(avatarId: "samurai_01"))
```

### Track a screen view

```swift
logManager.trackScreen(event: AppEvent.chatStarted(avatarId: "samurai_01"))
```

### User properties

```swift
logManager.addUserProperties(dict: ["plan": "premium"], isHighPriority: true)
```

### Delete user profile

```swift
logManager.deleteUserProfile()
```

## Built-in Services

### ConsoleService

Prints events to Xcode's console using `OSLog`. Useful during development.

```swift
ConsoleService(printParameters: true) // set false to suppress parameter output
```

## Implementing a Custom Service

Conform to `LogServiceProtocol` to route events to any backend:

```swift
struct MyAnalyticsService: LogServiceProtocol {
    func identify(userId: String, name: String?, email: String?) { ... }
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) { ... }
    func deleteUserProfile() { ... }
    func trackEvent(event: any LoggableEvent) { ... }
    func trackScreen(event: any LoggableEvent) { ... }
}
```

Then register it:

```swift
let logManager = LogManager(services: [ConsoleService(), MyAnalyticsService()])
```

## Log Types

| Case | When to use |
|------|-------------|
| `.info` | Internal/diagnostic messages, not analytics |
| `.analytic` | Standard product analytics events |
| `.warning` | Non-critical issues that shouldn't occur |
| `.severe` | Errors that negatively impact user experience |
