# VIPER Template Setup & Usage Guide

## Template Established

Your VIPER + Clean Architecture template has been successfully created and verified!

**Location**: `~/Library/Developer/Xcode/Templates/CustomTemplates/VIPERTemplate.xctemplate/`

## Verification Results

All features in the project follow the VIPER pattern correctly:

- **15 features verified** (About, Settings, Chat, Profile, Welcome, etc.)
- **All core files present** (View, Presenter, Interactor, Builder, Router)
- **Pattern consistency** across the entire codebase

## Template Structure

The template generates 5 files for each new feature:

```
YourFeature/
├── YourFeatureView.swift          # SwiftUI UI
├── YourFeaturePresenter.swift     # Presentation logic & state
├── YourFeatureInteractor.swift    # Business logic
├── YourFeatureBuilder.swift       # Dependency injection
└── YourFeatureRouter.swift        # Navigation
```

## How to Use the Template

### Method 1: In Xcode (Recommended)

1. **Open Xcode** and your AIChat project
2. **Right-click** on `AIChat/Core/` folder in Project Navigator
3. Select **New File...**
4. Scroll down to **Custom Templates** section
5. Select **VIPERTemplate**
6. Click **Next**
7. **Fill in the form**:
   - Feature Name (PascalCase): `YourFeature` (e.g., `Notifications`)
   - Feature Name (camelCase): `yourFeature` (e.g., `notifications`)
8. **Choose location**: Select `AIChat/Core/YourFeature/`
9. Click **Create**

### Method 2: Command Line

Run the feature creation script:
```bash
./create-feature.sh Notifications
```

### Verify Template Availability

If you don't see the template in Xcode:

```bash
# Check template exists
ls -la ~/Library/Developer/Xcode/Templates/CustomTemplates/VIPERTemplate.xctemplate/

# Should show:
# TemplateInfo.plist
# ___FILEBASENAME___View.swift
# ___FILEBASENAME___Presenter.swift
# ___FILEBASENAME___Interactor.swift
# ___FILEBASENAME___Builder.swift
# ___FILEBASENAME___Router.swift
```

**If template is missing**, restart Xcode or run:
```bash
# Restart Xcode
killall Xcode
open /Applications/Xcode.app
```

## Example: Creating a "Notifications" Feature

### Step 1: Use Template
1. In Xcode, create new file from VIPERTemplate
2. Enter:
   - Feature Name (PascalCase): `Notifications`
   - Feature Name (camelCase): `notifications`

### Step 2: Implement Business Logic

Edit `NotificationsInteractor.swift`:
```swift
@MainActor
final class NotificationsInteractor {
    private let logManager: LogManager?
    private let notificationManager: NotificationManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
        self.notificationManager = container.resolve(NotificationManager.self)
    }
}

extension NotificationsInteractor: NotificationsInteractorProtocol {
    func fetchNotifications() async throws -> [Notification] {
        try await notificationManager?.getNotifications() ?? []
    }
}
```

### Step 3: Implement Presentation Logic

Edit `NotificationsPresenter.swift`:
```swift
@Observable
@MainActor
class NotificationsPresenter {
    var notifications: [Notification] = []
    var isLoading = false

    private let notificationsInteractor: NotificationsInteractorProtocol
    private let router: NotificationsRouterProtocol

    func loadNotifications() async {
        isLoading = true
        do {
            notifications = try await notificationsInteractor.fetchNotifications()
        } catch {
            notificationsInteractor.trackEvent(event: Event.loadFailed)
        }
        isLoading = false
    }
}
```

### Step 4: Implement UI

Edit `NotificationsView.swift`:
```swift
struct NotificationsView: View {
    @State var presenter: NotificationsPresenter

    var body: some View {
        List(presenter.notifications) { notification in
            NotificationRow(notification: notification)
        }
        .navigationTitle("Notifications")
        .screenAppearAnalytics(name: "NotificationsView")
        .task {
            await presenter.loadNotifications()
        }
    }
}
```

### Step 5: Add to Navigation

In your parent router:
```swift
func navigateToNotifications() {
    let builder = NotificationsBuilder(container: container)
    router.push(builder.buildNotificationsView(router: router))
}
```

## Verification

After creating a new feature, verify it follows the pattern:

```bash
# Run verification script
./verify-architecture.sh

# Should show:
# ✅ All features follow the VIPER pattern!
```

## Project Architecture Compliance

| Feature | Status | Files |
|---------|--------|-------|
| About | Complete | 5/5 |
| Settings | Complete | 5/5 |
| Profile | Complete | 5/5 |
| Chat | Complete | 5/5 |
| Welcome | Complete | 5/5 |
| Chats | Complete | 5/5 |
| CreateAccount | Complete | 5/5 |
| CreateAvatar | Complete | 5/5 |
| DevSettings | Complete | 5/5 |
| Bookmarks | Complete | 5/5 |
| CategoryList | Complete | 5/5 |
| Explore | Complete | 5/5 |
| NewsDetails | Complete | 5/5 |
| NewsFeed | Complete | 5/5 |
| Paywall | Complete | 5/5 |

**Special Structures:**
- **Onboarding**: Composite feature with sub-features (IntroView, ColorView, etc.)
- **TabBar**: Navigation container
- **AppView**: Application entry point

## Key Architecture Principles

### 1. Separation of Concerns
- **View**: UI only, no business logic
- **Presenter**: Presentation logic, UI state management
- **Interactor**: Business logic, data operations
- **Builder**: Dependency injection
- **Router**: Navigation

### 2. Dependency Management
```swift
// Always resolve from DependencyContainer
let manager = container.resolve(ManagerType.self)

// Never create instances directly
// let manager = ProductionManager()
// let manager = container.resolve(ManagerType.self)
```

### 3. Protocol-Based Design
```swift
// Define protocol
protocol FeatureInteractorProtocol {
    func performAction() async throws
}

// Implement protocol
extension FeatureInteractor: FeatureInteractorProtocol {
    func performAction() async throws {
        // Implementation
    }
}
```

### 4. SwiftUI Best Practices
```swift
// Use @Observable (not ObservableObject)
@Observable
@MainActor
class FeaturePresenter {
    // Properties and methods
}

// Use @State in View
struct FeatureView: View {
    @State var presenter: FeaturePresenter
}
```

## Template Maintenance

### Updating the Template

If you need to update the template:

1. **Edit template files** in:
   ```
   XcodeTemplate/VIPERTemplate.xctemplate/
   ```

2. **Reinstall the template**:
   ```bash
   ./install-template.sh
   ```

3. **Test the template**:
   - Create a test feature in Xcode
   - Verify all files generate correctly
   - Check for syntax errors

4. **Update reference implementation**:
   - The **About** feature is the reference
   - Keep it synchronized with template changes

### Reference Implementation

The **About** feature (`AIChat/Core/About/`) serves as the reference implementation:
- Follows all architecture principles
- Includes all 5 core files
- Well-commented and documented
- Used as template baseline

When in doubt, refer to the About feature structure.

## Common Pitfalls to Avoid

### Don't
1. **Force unwrapping** (`!`) - SwiftLint will error
2. **Force try** (`try!`) - SwiftLint will error
3. **Direct service instantiation** - Always use DependencyContainer
4. **Mix concerns** - Keep View, Presenter, Interactor separate
5. **Skip protocols** - Always define protocol before implementation
6. **Forget @MainActor** - UI classes must be @MainActor

### Do
1. **Use optionals safely** - Use `if let`, `guard let`, or `??`
2. **Proper error handling** - Use `try`, `try?`, or `do-catch`
3. **Resolve dependencies** - Use `container.resolve(Type.self)`
4. **Follow separation** - View -> Presenter -> Interactor -> Manager
5. **Define protocols** - Protocol first, implementation second
6. **Mark UI classes** - Always use `@MainActor` for UI code

## Need Help?

If you encounter issues:

1. **Check the reference**: Look at `AIChat/Core/About/` feature
2. **Run verification**: `./verify-architecture.sh`
3. **Review documentation**: `CLAUDE.md` and template `README.md`
4. **Check SwiftLint**: Run `swiftlint lint` for code quality issues

## Summary

- **Template created** and verified
- **All 15 features** follow the pattern
- **Verification script** available
- **Documentation** complete
- **Ready to use** for new features

You can now create new features with consistent VIPER architecture using the Xcode template!
