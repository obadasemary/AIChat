# Log Service

The Log Service provides multi-destination logging for analytics, debugging, and crash reporting.

## Overview

The Log Service aggregates multiple logging destinations (Console, Mixpanel, Firebase Analytics, Crashlytics) into a unified interface for event tracking and error logging.

## Architecture

```
LogManager (Orchestration)
    ↓
LogServiceProtocol[]
    ↓
├── ConsoleService (Debug logging)
├── MixpanelService (Analytics)
├── FirebaseAnalyticsService (Analytics)
└── FirebaseCrashlyticsService (Crash reporting)
```

## Files

| File | Path |
|------|------|
| `LogManager.swift` | `Services/Logs/LogManager.swift` |
| `LogManagerProtocol.swift` | `Services/Logs/LogManagerProtocol.swift` |

### Services
| File | Path |
|------|------|
| `LogServiceProtocol.swift` | `Services/Logs/Services/LogServiceProtocol.swift` |
| `ConsoleService.swift` | `Services/Logs/Services/ConsoleService.swift` |
| `MixpanelService.swift` | `Services/Logs/Services/MixpanelService.swift` |
| `FirebaseAnalyticsService.swift` | `Services/Logs/Services/FirebaseAnalyticsService.swift` |
| `FirebaseCrashlyticsService.swift` | `Services/Logs/Services/FirebaseCrashlyticsService.swift` |
| `LogSystem.swift` | `Services/Logs/Services/LogSystem.swift` |

### Models
| File | Path |
|------|------|
| `LoggableEvent.swift` | `Services/Logs/Models/LoggableEvent.swift` |

## Protocol Definition

### LogManagerProtocol
```swift
protocol LogManagerProtocol {
    func trackEvent(_ event: LoggableEvent)
    func trackScreenView(screenName: String)
    func setUserId(_ userId: String?)
    func setUserProperty(key: String, value: String?)
}
```

### LogServiceProtocol
```swift
protocol LogServiceProtocol {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackScreenView(screenName: String)
    func setUserId(_ userId: String?)
    func setUserProperty(key: String, value: String?)
}
```

### LoggableEvent
```swift
protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}

enum LogType {
    case analytic    // Track in analytics
    case warning     // Log as warning
    case severe      // Log as error + crash reporting
}
```

## Usage

### Resolving from Container
```swift
let logManager = container.resolve(LogManager.self)
```

### Track Event
```swift
logManager.trackEvent(MyEvent.buttonTapped)
```

### Track Screen View
```swift
logManager.trackScreenView(screenName: "ChatView")
```

### Set User ID
```swift
logManager.setUserId(user.id)
```

### Define Custom Events
```swift
enum ChatEvent: LoggableEvent {
    case messageSent(chatId: String)
    case messageReceived(chatId: String)
    case chatDeleted(chatId: String)

    var eventName: String {
        switch self {
        case .messageSent: return "chat_message_sent"
        case .messageReceived: return "chat_message_received"
        case .chatDeleted: return "chat_deleted"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .messageSent(let chatId),
             .messageReceived(let chatId),
             .chatDeleted(let chatId):
            return ["chat_id": chatId]
        }
    }

    var type: LogType { .analytic }
}
```

## Log Services

### ConsoleService
Prints logs to Xcode console for debugging:
```swift
class ConsoleService: LogServiceProtocol {
    let printParameters: Bool

    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {
        let prefix = type == .severe ? "🔴" : type == .warning ? "🟡" : "📊"
        print("\(prefix) [\(eventName)]")
        if printParameters, let params = parameters {
            print("   Parameters: \(params)")
        }
    }
}
```

### MixpanelService
Sends events to Mixpanel for analytics:
```swift
class MixpanelService: LogServiceProtocol {
    private let mixpanel: MixpanelInstance

    init(token: String) {
        mixpanel = Mixpanel.initialize(token: token)
    }

    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {
        mixpanel.track(event: eventName, properties: parameters as? Properties)
    }

    func setUserId(_ userId: String?) {
        if let userId {
            mixpanel.identify(distinctId: userId)
        } else {
            mixpanel.reset()
        }
    }
}
```

### FirebaseAnalyticsService
Sends events to Firebase Analytics:
```swift
class FirebaseAnalyticsService: LogServiceProtocol {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {
        Analytics.logEvent(eventName, parameters: parameters)
    }

    func trackScreenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }
}
```

### FirebaseCrashlyticsService
Reports errors to Crashlytics:
```swift
class FirebaseCrashlyticsService: LogServiceProtocol {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType) {
        if type == .severe {
            Crashlytics.crashlytics().log("\(eventName): \(parameters ?? [:])")
        }
    }

    func setUserId(_ userId: String?) {
        Crashlytics.crashlytics().setUserID(userId ?? "")
    }
}
```

## Build Configuration

### Development (.dev)
```swift
logManager = LogManager(services: [
    ConsoleService(),
    FirebaseAnalyticsService(),
    MixpanelService(token: Keys.mixpanelToken),
    FirebaseCrashlyticsService()
])
```

### Production (.prod)
```swift
logManager = LogManager(services: [
    FirebaseAnalyticsService(),
    MixpanelService(token: Keys.mixpanelToken),
    FirebaseCrashlyticsService()
])
// Note: No ConsoleService in production
```

### Mock (.mock)
```swift
logManager = LogManager(services: [
    ConsoleService(printParameters: false)
])
```

## Event Naming Conventions

```
{ScreenName}_{Action}_{Result}

Examples:
- ChatView_SendMessage_Start
- ChatView_SendMessage_Success
- ChatView_SendMessage_Fail
- ProfileView_ColorChanged
- PaywallView_Purchase_Completed
```

## Related Documentation

- [All Feature Documentation](../features/)
- [Troubleshooting Guide](../TROUBLESHOOTING.md)
