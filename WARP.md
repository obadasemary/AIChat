# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Build & Development Commands

### Building the Project
```bash
# Open in Xcode
open AIChat.xcodeproj

# Build from command line (Development scheme)
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

# Build with Mock data (for testing)
xcodebuild clean build \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Mock" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

### Testing
```bash
# Run unit tests only
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:AIChatTests

# Run UI tests only
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:AIChatUITests

# Run all tests (unit + UI)
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'

# Run specific test class
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:AIChatTests/YourTestClassName

# Run with test plan (Development)
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Development" \
  -testPlan "AIChat - Development" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'

# Run with test plan (Mock)
xcodebuild test \
  -project AIChat.xcodeproj \
  -scheme "AIChat - Mock" \
  -testPlan "AIChat - Mock" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

### Linting
```bash
# Run SwiftLint on the entire project
swiftlint lint

# Run SwiftLint with auto-fix
swiftlint lint --fix

# Run SwiftLint on specific files
swiftlint lint --path AIChat/Core/Chat/ChatView.swift
```

## Architecture Overview

### High-Level Architecture
AIChat follows **Clean Architecture** with **MVVM** pattern and uses the **Builder Pattern** for dependency injection.

**Key Architectural Concepts:**
1. **Triple-layer separation**: View → ViewModel → UseCase
2. **Dependencies are injected via DependencyContainer** - all managers are registered centrally
3. **Routing is handled by Router objects** using the SUIRouting library
4. **Builders construct views with their dependencies** - each feature has its own Builder
5. **Three build configurations** (.mock, .dev, .prod) with different service implementations

### Core Components

#### 1. App Entry & Dependency Management
- **`AIChat/App/AIChatApp.swift`**: Main app entry point
- **`AIChat/App/AppDelegate.swift`**: App lifecycle and push notifications
- **`AIChat/App/Dependencies.swift`**: Central dependency container configuration
  - Configures ALL managers (Auth, User, AI, Avatar, Chat, Log, Push, ABTest, Purchase)
  - Registers services based on build configuration (.mock, .dev, .prod)
  - `.mock`: Uses mock services for testing
  - `.dev`: Uses real services + console logging + analytics
  - `.prod`: Uses real services + analytics only (no console logs)
- **`AIChat/App/DependencyContainer.swift`**: Service locator pattern implementation

#### 2. Feature Structure Pattern
Every feature follows this structure:
```
Feature/
├── FeatureView.swift          # SwiftUI view
├── FeatureViewModel.swift     # View logic & state
├── FeatureUseCase.swift       # Business logic (accesses managers)
├── FeatureBuilder.swift       # Dependency injection & construction
└── FeatureRouter.swift        # Navigation (if needed)
```

**Example: Chat Feature**
- `ChatView` → displays UI
- `ChatViewModel` → manages view state, calls UseCase methods
- `ChatUseCase` → accesses `AIManager` and `ChatManager` from container
- `ChatBuilder` → creates ChatView with injected dependencies
- `ChatDelegate` → protocol for parent view communication

#### 3. Services Layer (`AIChat/Services/`)
Services are protocol-based with multiple implementations:
- **AI Service**: `AIManager` → `OpenAIServer` (prod) / `MockAIServer` (mock)
- **Auth Service**: `AuthManager` → `FirebaseAuthService` / `MockAuthService`
- **User Service**: `UserManager` → `ProductionUserServices` / `MockUserServices`
- **Avatar Service**: `AvatarManager` → `FirebaseAvatarService` / `MockAvatarService`
- **Chat Service**: `ChatManager` → `FirebaseChatService` / `MockChatService`
- **Purchase Service**: `PurchaseManager` → `StoreKitPurchaseService` / `MockPurchaseService`
- **ABTest Service**: `ABTestManager` → `FirebaseABTestService` / `LocalABTestService`
- **Log Service**: `LogManager` → Multiple services (Console, Mixpanel, Firebase Analytics, Crashlytics)

#### 4. Configuration Management
- **`AIChat/Utilities/ConfigurationManager.swift`**: Centralized config loader
  - Loads API keys from `Config.plist` OR environment variables
  - Loads Firebase config files based on build configuration
  - **IMPORTANT**: Config files are NOT committed - use templates
  - Template files: `Config.template.plist`, `GoogleService-Info-Dev.template.plist`, `GoogleService-Info-Prod.template.plist`

#### 5. Routing & Navigation
- Uses **SUIRouting** library for declarative routing
- Each feature can have a Router (e.g., `ChatRouter`, `CoreRouter`)
- `CoreBuilder` acts as the main view factory for all features
- Builders are injected as SwiftUI environment objects

### Data Flow Example
```
User Action → View → ViewModel → UseCase → Manager → Service → External API
                ↓                    ↓          ↓         ↓
            State Update ← Business Logic ← Data Transform ← Response
```

## Important Development Notes

### Configuration Setup (First-time setup)
1. Copy template files:
   ```bash
   cp Config.template.plist Config.plist
   cp GoogleService-Info-Dev.template.plist GoogleService-Info-Dev.plist
   cp GoogleService-Info-Prod.template.plist GoogleService-Info-Prod.plist
   ```
2. Edit `Config.plist` and add real API keys (OpenAI, Mixpanel)
3. Edit Firebase plist files with real Firebase config
4. Add all three files to Xcode project (verify target membership)
5. **NEVER commit these files** - they are gitignored

### Build Configurations
- **Development** (`.dev`): Real services + console logging + analytics
- **Production** (`.prod`): Real services + analytics only
- **Mock** (`.mock`): Mock services for UI testing
- Firebase configuration is selected automatically based on build config

### Testing Strategy
- **Unit Tests** (`AIChatTests/`): Test business logic with mock services
- **UI Tests** (`AIChatUITests/`): Test user flows with mock data
- **Test Plans**:
  - `AIChat - Development.xctestplan`: Runs all tests with code coverage
  - `AIChat - Mock.xctestplan`: Runs UI tests only with mock data
- To test with mock data, use the "AIChat - Mock" scheme
- UI tests can trigger specific A/B test variants using launch arguments (e.g., `ONBOARDING_COMMUNITY_TEST`)

### SwiftLint Configuration
- Config file: `.swiftlint.yml`
- Many rules are disabled for flexibility (identifier_name, type_name, etc.)
- **Force unwrapping is an ERROR** - avoid `!` operator
- **Force try is an ERROR** - avoid `try!`
- Function body length: max 50 lines
- Line length: max 400 characters
- Type body length: max 400 lines

### Code Style Guidelines
- Use **4-space indentation** (project standard)
- Follow **MVVM pattern** strictly
- Use **protocol-oriented programming** for services
- Use **Builder pattern** for dependency injection
- Keep files under 500 lines
- Test naming: `test_whenCondition_thenExpectedBehavior()`
- Use descriptive names (avoid abbreviations)

### Key Patterns to Follow

#### 1. Dependency Injection via DependencyContainer
```swift
// In UseCase
let aiManager = container.resolve(AIManager.self)
let chatManager = container.resolve(ChatManager.self)
```

#### 2. Builder Pattern
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

#### 3. View Construction with Builder
```swift
struct ParentView: View {
    @Environment(FeatureBuilder.self) var featureBuilder
    
    var body: some View {
        featureBuilder.buildFeatureView()
    }
}
```

### Common Pitfalls to Avoid
1. **DO NOT use force unwrapping (`!`)** - SwiftLint will error
2. **DO NOT use `try!`** - SwiftLint will error
3. **DO NOT bypass DependencyContainer** - always resolve dependencies from container
4. **DO NOT hardcode API keys** - use ConfigurationManager
5. **DO NOT create service instances directly** - use managers from container
6. **DO NOT forget to register new services** in `Dependencies.swift`
7. **DO NOT commit Config.plist** or Firebase plist files
8. **DO NOT mix view logic with business logic** - keep UseCase and ViewModel separate

### File Location Conventions
- Features: `AIChat/Core/{FeatureName}/`
- Services: `AIChat/Services/{ServiceType}/`
- Reusable UI: `AIChat/Components/`
- Utilities: `AIChat/Utilities/`
- App setup: `AIChat/App/`
- Tests: `AIChatTests/` and `AIChatUITests/`
