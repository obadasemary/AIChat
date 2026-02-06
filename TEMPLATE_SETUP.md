# MVVM Template Setup & Usage Guide

## ✅ Template Established

Your MVVM + Clean Architecture template has been successfully created and verified!

**Location**: `~/Library/Developer/Xcode/Templates/CustomTemplates/MVVMTemplate.xctemplate/`

## 📋 Verification Results

All features in the project follow the MVVM pattern correctly:

✅ **15 features verified** (About, Settings, Chat, Profile, Welcome, etc.)
✅ **All core files present** (View, ViewModel, UseCase, Builder, Router)
✅ **Pattern consistency** across the entire codebase

## 🎯 Template Structure

The template generates 5 files for each new feature:

```
YourFeature/
├── YourFeatureView.swift          # SwiftUI UI
├── YourFeatureViewModel.swift     # Presentation logic
├── YourFeatureUseCase.swift       # Business logic
├── YourFeatureBuilder.swift       # Dependency injection
└── YourFeatureRouter.swift        # Navigation
```

## 🚀 How to Use the Template

### Method 1: In Xcode (Recommended)

1. **Open Xcode** and your AIChat project
2. **Right-click** on `AIChat/Core/` folder in Project Navigator
3. Select **New File...**
4. Scroll down to **Custom Templates** section
5. Select **MVVMTemplate**
6. Click **Next**
7. **Fill in the form**:
   - Module Name: `YourFeature` (PascalCase)
   - camelCased Name: `yourFeature` (camelCase)
   - Core Router Name: `Core` (default)
8. **Choose location**: Select `AIChat/Core/YourFeature/`
9. Click **Create**

### Method 2: Verify Template Availability

If you don't see the template in Xcode:

```bash
# Check template exists
ls -la ~/Library/Developer/Xcode/Templates/CustomTemplates/MVVMTemplate.xctemplate/

# Should show:
# TemplateInfo.plist
# ___FILEBASENAME___View.swift
# ___FILEBASENAME___ViewModel.swift
# ___FILEBASENAME___UseCase.swift
# ___FILEBASENAME___Builder.swift
# ___FILEBASENAME___Router.swift
# README.md
```

**If template is missing**, restart Xcode or run:
```bash
# Restart Xcode
killall Xcode
open /Applications/Xcode.app
```

## 📝 Example: Creating a "Notifications" Feature

### Step 1: Use Template
1. In Xcode, create new file from MVVMTemplate
2. Enter:
   - Module Name: `Notifications`
   - camelCased Name: `notifications`
   - Core Router Name: `Core`

### Step 2: Implement Business Logic

Edit `NotificationsUseCase.swift`:
```swift
@MainActor
final class NotificationsUseCase {
    private let logManager: LogManager?
    private let notificationManager: NotificationManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
        self.notificationManager = container.resolve(NotificationManager.self)
    }
}

extension NotificationsUseCase: NotificationsUseCaseProtocol {
    func fetchNotifications() async throws -> [Notification] {
        try await notificationManager?.getNotifications() ?? []
    }
}
```

### Step 3: Implement UI

Edit `NotificationsView.swift`:
```swift
struct NotificationsView: View {
    @State var viewModel: NotificationsViewModel

    var body: some View {
        List(viewModel.notifications) { notification in
            NotificationRow(notification: notification)
        }
        .navigationTitle("Notifications")
        .screenAppearAnalytics(name: "NotificationsView")
        .task {
            await viewModel.loadNotifications()
        }
    }
}
```

### Step 4: Add to Navigation

In your parent router:
```swift
func navigateToNotifications() {
    let builder = NotificationsBuilder(container: container)
    router.push(builder.buildNotificationsView(router: router))
}
```

## 🔍 Verification

After creating a new feature, verify it follows the pattern:

```bash
# Run verification script
./verify-architecture.sh

# Should show:
# ✅ All features follow the MVVM pattern!
```

## 📊 Project Architecture Compliance

| Feature | Status | Files |
|---------|--------|-------|
| About | ✅ Complete | 5/5 |
| Settings | ✅ Complete | 5/5 |
| Profile | ✅ Complete | 5/5 |
| Chat | ✅ Complete | 5/5 |
| Welcome | ✅ Complete | 5/5 |
| Chats | ✅ Complete | 5/5 |
| CreateAccount | ✅ Complete | 5/5 |
| CreateAvatar | ✅ Complete | 5/5 |
| DevSettings | ✅ Complete | 5/5 |
| Bookmarks | ✅ Complete | 5/5 |
| CategoryList | ✅ Complete | 5/5 |
| Explore | ✅ Complete | 5/5 |
| NewsDetails | ✅ Complete | 5/5 |
| NewsFeed | ✅ Complete | 5/5 |
| Paywall | ✅ Complete | 5/5 |

**Special Structures:**
- **Onboarding**: Composite feature with sub-features (IntroView, ColorView, etc.)
- **TabBar**: Navigation container
- **AppView**: Application entry point

## 📚 Key Architecture Principles

### 1. Separation of Concerns
- **View**: UI only, no business logic
- **ViewModel**: Presentation logic, UI state
- **UseCase**: Business logic, data operations
- **Builder**: Dependency injection
- **Router**: Navigation

### 2. Dependency Management
```swift
// Always resolve from DependencyContainer
let manager = container.resolve(ManagerType.self)

// Never create instances directly
// ❌ let manager = ProductionManager()
// ✅ let manager = container.resolve(ManagerType.self)
```

### 3. Protocol-Based Design
```swift
// Define protocol
protocol FeatureUseCaseProtocol {
    func performAction() async throws
}

// Implement protocol
extension FeatureUseCase: FeatureUseCaseProtocol {
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
class FeatureViewModel {
    // Use @State in View
    @State var viewModel: FeatureViewModel
}
```

## 🛠️ Template Maintenance

### Updating the Template

If you need to update the template:

1. **Edit template files** in:
   ```
   ~/Library/Developer/Xcode/Templates/CustomTemplates/MVVMTemplate.xctemplate/
   ```

2. **Test the template**:
   - Create a test feature in Xcode
   - Verify all files generate correctly
   - Check for syntax errors

3. **Update reference implementation**:
   - The **About** feature is the reference
   - Keep it synchronized with template changes

4. **Update documentation**:
   - `TEMPLATE_SETUP.md` (this file)
   - `CLAUDE.md` (architecture section)
   - Template's `README.md`

### Reference Implementation

The **About** feature (`AIChat/Core/About/`) serves as the reference implementation:
- ✅ Follows all architecture principles
- ✅ Includes all 5 core files
- ✅ Well-commented and documented
- ✅ Used as template baseline

When in doubt, refer to the About feature structure.

## 🚨 Common Pitfalls to Avoid

### ❌ DON'T
1. **Force unwrapping** (`!`) - SwiftLint will error
2. **Force try** (`try!`) - SwiftLint will error
3. **Direct service instantiation** - Always use DependencyContainer
4. **Mix concerns** - Keep View, ViewModel, UseCase separate
5. **Skip protocols** - Always define protocol before implementation
6. **Forget @MainActor** - UI classes must be @MainActor

### ✅ DO
1. **Use optionals safely** - Use `if let`, `guard let`, or `??`
2. **Proper error handling** - Use `try`, `try?`, or `do-catch`
3. **Resolve dependencies** - Use `container.resolve(Type.self)`
4. **Follow separation** - View → ViewModel → UseCase → Manager
5. **Define protocols** - Protocol first, implementation second
6. **Mark UI classes** - Always use `@MainActor` for UI code

## 📞 Need Help?

If you encounter issues:

1. **Check the reference**: Look at `AIChat/Core/About/` feature
2. **Run verification**: `./verify-architecture.sh`
3. **Review documentation**: `CLAUDE.md` and template `README.md`
4. **Check SwiftLint**: Run `swiftlint lint` for code quality issues

## 🎉 Summary

✅ **Template created** and verified
✅ **All 15 features** follow the pattern
✅ **Verification script** available
✅ **Documentation** complete
✅ **Ready to use** for new features

You can now create new features with consistent architecture using the Xcode template!
