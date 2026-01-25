# AB Test Service

The AB Test Service manages A/B testing and feature flag experiments.

## Overview

The AB Test Service provides A/B testing capabilities through Firebase Remote Config with support for local testing and mock variants.

## Architecture

```
ABTestManager (Orchestration)
    ↓
ABTestServiceProtocol
    ↓
├── FirebaseABTestService (Production)
├── LocalABTestService (Development)
└── MockABTestService (Testing)
```

## Files

| File | Path |
|------|------|
| `ABTestManager.swift` | `Services/ABTests/ABTestManager.swift` |
| `ABTestManagerProtocol.swift` | `Services/ABTests/ABTestManagerProtocol.swift` |

### Services
| File | Path |
|------|------|
| `ABTestServiceProtocol.swift` | `Services/ABTests/Services/ABTestServiceProtocol.swift` |
| `FirebaseABTestService.swift` | `Services/ABTests/Services/FirebaseABTestService.swift` |
| `LocalABTestService.swift` | `Services/ABTests/Services/LocalABTestService.swift` |
| `MockABTestService.swift` | `Services/ABTests/Services/MockABTestService.swift` |

### Models
| File | Path |
|------|------|
| `ActiveABTests.swift` | `Services/ABTests/Models/ActiveABTests.swift` |
| `CategoryRowTestOption.swift` | `Services/ABTests/Models/CategoryRowTestOption.swift` |

## Protocol Definition

### ABTestManagerProtocol
```swift
protocol ABTestManagerProtocol {
    func fetchConfig() async throws
    func getVariant<T: ABTestVariant>(for test: ABTest<T>) -> T
    func isFeatureEnabled(_ feature: FeatureFlag) -> Bool
}
```

### ABTestServiceProtocol
```swift
protocol ABTestServiceProtocol {
    func fetchConfig() async throws
    func getString(for key: String) -> String?
    func getBool(for key: String) -> Bool
    func getInt(for key: String) -> Int
}
```

## Usage

### Resolving from Container
```swift
let abTestManager = container.resolve(ABTestManager.self)
```

### Get Test Variant
```swift
let variant = abTestManager.getVariant(for: .onboardingCommunity)

switch variant {
case .control:
    // Show control experience
case .variantA:
    // Show variant A
case .variantB:
    // Show variant B
}
```

### Check Feature Flag
```swift
if abTestManager.isFeatureEnabled(.newChatUI) {
    // Show new chat UI
} else {
    // Show old chat UI
}
```

## Defining Tests

### ABTest Definition
```swift
struct ABTest<T: ABTestVariant> {
    let key: String
    let defaultVariant: T
}

extension ABTest {
    static var onboardingCommunity: ABTest<OnboardingCommunityVariant> {
        ABTest(key: "onboarding_community_test", defaultVariant: .control)
    }

    static var categoryRowStyle: ABTest<CategoryRowTestOption> {
        ABTest(key: "category_row_style", defaultVariant: .standard)
    }
}
```

### Variant Definitions
```swift
enum OnboardingCommunityVariant: String, ABTestVariant {
    case control
    case variantA = "variant_a"
    case variantB = "variant_b"
}

enum CategoryRowTestOption: String, ABTestVariant {
    case standard
    case compact
    case expanded
}
```

### Feature Flags
```swift
enum FeatureFlag: String {
    case newChatUI = "feature_new_chat_ui"
    case darkModeSupport = "feature_dark_mode"
    case pushNotifications = "feature_push_notifications"
}
```

## Build Configuration

### Development (.dev)
```swift
abTestManager = ABTestManager(
    service: LocalABTestService(),
    logManager: logManager
)
```

### Production (.prod)
```swift
abTestManager = ABTestManager(
    service: FirebaseABTestService(),
    logManager: logManager
)
```

### Mock (.mock)
```swift
let isInOnboardingCommunityTest = ProcessInfo
    .processInfo
    .arguments
    .contains("ONBOARDING_COMMUNITY_TEST")

abTestManager = ABTestManager(
    service: MockABTestService(
        onboardingCommunityTest: isInOnboardingCommunityTest
    ),
    logManager: logManager
)
```

## Firebase Remote Config

### Configuration
```swift
class FirebaseABTestService: ABTestServiceProtocol {
    private let remoteConfig = RemoteConfig.remoteConfig()

    func fetchConfig() async throws {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        remoteConfig.configSettings = settings

        try await remoteConfig.fetch()
        try await remoteConfig.activate()
    }

    func getString(for key: String) -> String? {
        remoteConfig.configValue(forKey: key).stringValue
    }
}
```

### Remote Config Setup
In Firebase Console:
1. Go to Remote Config
2. Add parameters matching test keys
3. Set default values
4. Create A/B test experiments

## Local Testing

### LocalABTestService
For development without Firebase:
```swift
class LocalABTestService: ABTestServiceProtocol {
    private var config: [String: Any] = [
        "onboarding_community_test": "control",
        "category_row_style": "standard",
        "feature_new_chat_ui": true
    ]

    func getString(for key: String) -> String? {
        config[key] as? String
    }

    func getBool(for key: String) -> Bool {
        config[key] as? Bool ?? false
    }
}
```

## Testing with Launch Arguments

For UI tests, trigger specific variants:
```swift
// In UI test
app.launchArguments.append("ONBOARDING_COMMUNITY_TEST")
app.launch()
```

```swift
// In MockABTestService
init(onboardingCommunityTest: Bool = false) {
    self.variants = [
        "onboarding_community_test": onboardingCommunityTest ? "variant_a" : "control"
    ]
}
```

## Analytics Integration

Track variant assignments:
```swift
func getVariant<T: ABTestVariant>(for test: ABTest<T>) -> T {
    let variant = service.getString(for: test.key)
        .flatMap { T(rawValue: $0) } ?? test.defaultVariant

    // Log variant assignment
    logManager.trackEvent(ABTestEvent.variantAssigned(
        test: test.key,
        variant: variant.rawValue
    ))

    return variant
}
```

## Best Practices

1. **Always define default variants** for graceful fallback
2. **Log variant assignments** for analysis
3. **Use feature flags** for gradual rollouts
4. **Test all variants** in UI tests
5. **Clean up old tests** after conclusion

## Related Documentation

- [Onboarding Feature](../features/ONBOARDING.md)
- [Dev Settings Feature](../features/DEV_SETTINGS.md)
- [Log Service](./LOG_SERVICE.md)
