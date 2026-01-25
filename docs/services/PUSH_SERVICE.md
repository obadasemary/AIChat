# Push Service

The Push Service manages push notification registration and handling.

## Overview

The Push Service handles APNs registration, notification permissions, and push notification processing.

## Architecture

```
PushManager (Orchestration)
    ↓
PushManagerProtocol
    ↓
└── PushManager (Implementation)
```

## Files

| File | Path |
|------|------|
| `PushManager.swift` | `Services/PushNotifications/PushManager.swift` |
| `PushManagerProtocol.swift` | `Services/PushNotifications/PushManagerProtocol.swift` |

## Protocol Definition

### PushManagerProtocol
```swift
protocol PushManagerProtocol {
    var isRegistered: Bool { get }
    var deviceToken: String? { get }

    func requestPermission() async -> Bool
    func registerForRemoteNotifications()
    func handleDeviceToken(_ token: Data)
    func handleNotification(_ userInfo: [AnyHashable: Any])
}
```

## Usage

### Resolving from Container
```swift
let pushManager = container.resolve(PushManager.self)
```

### Request Permission
```swift
let granted = await pushManager.requestPermission()
if granted {
    pushManager.registerForRemoteNotifications()
}
```

### Handle Device Token
```swift
// In AppDelegate
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    pushManager.handleDeviceToken(deviceToken)
}
```

### Handle Notification
```swift
// In AppDelegate
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
) async -> UIBackgroundFetchResult {
    pushManager.handleNotification(userInfo)
    return .newData
}
```

## Implementation

### PushManager
```swift
@MainActor
@Observable
class PushManager: PushManagerProtocol {
    private let logManager: LogManager
    private(set) var isRegistered = false
    private(set) var deviceToken: String?

    init(logManager: LogManager) {
        self.logManager = logManager
    }

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            logManager.trackEvent(PushEvent.permissionResult(granted: granted))
            return granted
        } catch {
            logManager.trackEvent(PushEvent.permissionError(error: error))
            return false
        }
    }

    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func handleDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        deviceToken = tokenString
        isRegistered = true
        logManager.trackEvent(PushEvent.tokenReceived)

        // Send token to your server
        Task {
            await sendTokenToServer(tokenString)
        }
    }

    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        logManager.trackEvent(PushEvent.notificationReceived(userInfo: userInfo))

        // Process notification payload
        if let type = userInfo["type"] as? String {
            handleNotificationType(type, userInfo: userInfo)
        }
    }
}
```

## Notification Types

### Payload Structure
```json
{
  "aps": {
    "alert": {
      "title": "New Message",
      "body": "You have a new message from Alpha"
    },
    "badge": 1,
    "sound": "default"
  },
  "type": "new_message",
  "chat_id": "chat_123",
  "avatar_id": "avatar_456"
}
```

### Handling Different Types
```swift
private func handleNotificationType(_ type: String, userInfo: [AnyHashable: Any]) {
    switch type {
    case "new_message":
        if let chatId = userInfo["chat_id"] as? String {
            // Navigate to chat
            NotificationCenter.default.post(
                name: .openChat,
                object: nil,
                userInfo: ["chatId": chatId]
            )
        }

    case "new_avatar":
        if let avatarId = userInfo["avatar_id"] as? String {
            // Navigate to avatar
        }

    default:
        break
    }
}
```

## AppDelegate Integration

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    @Dependency var pushManager: PushManager

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        pushManager.handleDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        pushManager.handleNotification(userInfo)
    }
}
```

## Build Configuration

### All Configurations
```swift
pushManager = PushManager(logManager: logManager)
```

Note: Push notifications require real device testing. They don't work in simulator.

## Firebase Cloud Messaging (Optional)

If using FCM instead of raw APNs:

```swift
import FirebaseMessaging

extension PushManager: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }
        deviceToken = token
        // Send FCM token to server
    }
}
```

## Analytics Events

| Event | Description |
|-------|-------------|
| `push_permission_requested` | Permission dialog shown |
| `push_permission_granted` | User allowed notifications |
| `push_permission_denied` | User denied notifications |
| `push_token_received` | Device token received |
| `push_notification_received` | Notification received |
| `push_notification_tapped` | User tapped notification |

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Permission denied | User declined | Prompt again later or show settings |
| Registration failed | APNs error | Retry registration |
| Token refresh | Token invalidated | Re-register |

## Testing

### Local Notifications (Simulator)
```swift
func sendTestNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Test"
    content.body = "Test notification"

    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 1,
        repeats: false
    )

    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
}
```

### Remote Notifications (Device)
Use Firebase Console, Pusher, or custom server to send test notifications.

## Related Documentation

- [AppDelegate Documentation](../features/APP_DELEGATE.md)
- [Log Service](./LOG_SERVICE.md)
