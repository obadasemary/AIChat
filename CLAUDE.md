# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

### Building the Project
```bash
# Open in Xcode
open AIChat.xcodeproj

# Build for Development
xcodebuild clean build \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'

# Build for Production
xcodebuild clean build \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Production" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'

# Build with Mock data (for testing without external services)
xcodebuild clean build \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Mock" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

### Running Tests
```bash
# Run all tests (unit + UI)
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'

# Run unit tests only
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:AIChatTests

# Run specific test class
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:AIChatTests/TestClassName

# Run specific test method
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:AIChatTests/TestClassName/testMethodName
```

### Linting
```bash
# Run SwiftLint on entire project
swiftlint lint

# Run SwiftLint with auto-fix
swiftlint lint --fix

# Run SwiftLint on specific files
swiftlint lint --path AIChat/Core/Chat/ChatView.swift
```

## Architecture Overview

### Clean Architecture with MVVM Pattern
AIChat follows **Clean Architecture** principles with **MVVM** pattern and **Builder Pattern** for dependency injection.

**Core Architectural Concepts:**
1. **Three-layer separation**: View → ViewModel → UseCase
2. **Centralized dependency management** via `DependencyContainer` (service locator pattern)
3. **Protocol-based services** with multiple implementations (production, mock)
4. **Builder pattern** for view construction with dependency injection
5. **Three build configurations** (.mock, .dev, .prod) with different service implementations

### Feature Structure Pattern
Every feature follows this consistent structure:
```
Feature/
├── FeatureView.swift          # SwiftUI view (UI only)
├── FeatureViewModel.swift     # View state & presentation logic
├── FeatureUseCase.swift       # Business logic (accesses managers)
├── FeatureBuilder.swift       # Dependency injection & view construction
└── FeatureRouter.swift        # Navigation (optional)
```

**Example Data Flow:**
```
User Action → View → ViewModel → UseCase → Manager → Service → External API
                ↓         ↓          ↓         ↓         ↓
            State Update ← Presentation ← Business Logic ← Response
```

### Dependency Injection System

**DependencyContainer** (`AIChat/App/DependencyContainer.swift`):
- Service locator pattern for managing dependencies
- All managers are registered centrally in `Dependencies.swift`
- UseCases resolve dependencies from container: `container.resolve(AIManager.self)`

**Dependencies.swift** (`AIChat/App/Dependencies.swift`):
- Central configuration for all managers
- Registers different service implementations based on build configuration
- **Mock configuration**: Uses mock services, no real API calls
- **Dev configuration**: Real services + console logging + analytics
- **Production configuration**: Real services + analytics only (no console logs)

### Build Configurations

**Three Xcode schemes with corresponding build configurations:**

1. **AIChat - Development** (`.dev`):
   - Real Firebase, OpenAI, Mixpanel services
   - Console logging enabled for debugging
   - Analytics enabled (Mixpanel, Firebase Analytics)
   - Uses `GoogleService-Info-Dev.plist`

2. **AIChat - Production** (`.prod`):
   - Real Firebase, OpenAI, Mixpanel services
   - Console logging DISABLED (production-ready)
   - Analytics enabled (Mixpanel, Firebase Analytics)
   - Uses `GoogleService-Info-Prod.plist`

3. **AIChat - Mock** (`.mock`):
   - Mock services for all external dependencies
   - No real API calls (perfect for UI testing)
   - Can simulate signed-in or signed-out state
   - Launch arguments can trigger A/B test variants (e.g., `ONBOARDING_COMMUNITY_TEST`)

### Services Architecture

All services are protocol-based with multiple implementations:

```
AIChat/Services/
├── AI/                        # OpenAI integration
│   ├── AIManager.swift        # Protocol
│   ├── OpenAIServer.swift     # Production
│   └── MockAIServer.swift     # Mock
├── Auth/                      # Firebase authentication
│   ├── AuthManager.swift      # Protocol
│   ├── FirebaseAuthService    # Production
│   └── MockAuthService        # Mock
├── User/                      # User profile management
├── Avatar/                    # Avatar creation/storage
├── Chat/                      # Chat persistence
├── Purchases/                 # In-app purchases (StoreKit)
├── PushNotifications/         # Push notification handling
├── ABTests/                   # A/B testing framework
└── Logs/                      # Multi-service logging
    ├── ConsoleService
    ├── MixpanelService
    ├── FirebaseAnalyticsService
    └── CrashlyticsService
```

## Configuration Management

### First-Time Setup
1. Copy configuration templates:
   ```bash
   cp Config.template.plist Config.plist
   cp GoogleService-Info-Dev.template.plist GoogleService-Info-Dev.plist
   cp GoogleService-Info-Prod.template.plist GoogleService-Info-Prod.plist
   ```
2. Edit `Config.plist` and add real API keys (OpenAI, Mixpanel)
3. Edit Firebase plist files with real Firebase configuration
4. Add all three files to Xcode project (verify target membership)
5. **NEVER commit these files** - they are gitignored

### ConfigurationManager
- **Location**: `AIChat/Utilities/ConfigurationManager.swift`
- Supports loading API keys from:
  1. `Config.plist` (recommended for development)
  2. Environment variables (recommended for CI/CD)
- Automatically selects Firebase config based on build configuration
- Template files are safe to commit; real config files are gitignored

## Critical Development Guidelines

### SwiftLint Rules
- **Force unwrapping (`!`) is an ERROR** - avoid at all costs (unless explicitly disabled with swiftlint comment)
- **Force try (`try!`) is an ERROR** - use proper error handling
- Function body length: max 50 lines
- Line length: max 160 characters
- Type body length: max 400 lines
- Use 4-space indentation

### Dependency Injection Pattern
**ALWAYS use DependencyContainer to resolve dependencies:**
```swift
// In UseCase
let aiManager = container.resolve(AIManager.self)
let chatManager = container.resolve(ChatManager.self)
```

**DO NOT create service instances directly** - always resolve from container.

### Builder Pattern for View Construction
```swift
@Observable class FeatureBuilder {
    let container: DependencyContainer

    func buildFeatureView() -> some View {
        FeatureView(
            viewModel: FeatureViewModel(
                featureUseCase: FeatureUseCase(container: container)
            )
        )
    }
}
```

### Test Naming Convention
```swift
func test_whenUserTapsSendButton_thenMessageIsSent() {
    // Test implementation
}
```

## Common Pitfalls to Avoid

1. **DO NOT use force unwrapping (`!`)** - SwiftLint will error
2. **DO NOT use `try!`** - SwiftLint will error
3. **DO NOT bypass DependencyContainer** - always resolve dependencies
4. **DO NOT hardcode API keys** - use ConfigurationManager
5. **DO NOT create service instances directly** - use managers from container
6. **DO NOT forget to register new services** in `Dependencies.swift`
7. **DO NOT commit Config.plist or Firebase plist files** - they are gitignored
8. **DO NOT mix view logic with business logic** - keep UseCase and ViewModel separate
9. **DO NOT assume simulator names** - use 'iPhone 17 Pro' or 'OS=latest' for compatibility

## File Organization

```
AIChat/
├── App/                       # Application entry points and dependencies
│   ├── AIChatApp.swift       # Main app entry point
│   ├── AppDelegate.swift     # App lifecycle, push notifications
│   ├── Dependencies.swift    # Central dependency configuration
│   └── DependencyContainer.swift # Service locator pattern
├── Core/                      # Feature modules
│   ├── Chat/                 # AI chat functionality
│   ├── Chats/                # Chat list management
│   ├── Profile/              # User profile
│   ├── Settings/             # App settings
│   ├── Onboarding/           # User onboarding
│   └── Paywall/              # Subscription management
├── Services/                  # External service integrations
├── Components/                # Reusable UI components
├── Utilities/                 # Helper functions and extensions
└── Assets.xcassets/          # App icons and visual assets

Tests/
├── AIChatTests/              # Unit tests
└── AIChatUITests/            # UI tests
```

## Testing Strategy

### Unit Tests
- Test business logic with mock services
- Located in `AIChatTests/`
- Use "AIChat - Development" or "AIChat - Mock" scheme

### UI Tests
- Test user flows with mock data
- Located in `AIChatUITests/`
- Use "AIChat - Mock" scheme for isolated testing
- Can trigger A/B test variants via launch arguments

### Test Plans
- `AIChat - Development.xctestplan`: All tests with code coverage
- `AIChat - Mock.xctestplan`: UI tests only with mock data

## CI/CD

GitHub Actions workflow (`.github/workflows/CI.yml`):
- Runs on every push to `main` and all pull requests
- Uses `macos-26` runner with Xcode 26
- Builds with "AIChat - Development" scheme
- Runs unit tests on all branches
- Runs UI tests only on `main` branch (with retry logic)
- Creates mock Firebase config files for CI builds
