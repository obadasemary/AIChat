# MVVM + Clean Architecture Template for AIChat

This Xcode template generates a complete feature module following the **MVVM + Clean Architecture** pattern used throughout the AIChat project.

## 🏗️ Architecture Overview

Each feature follows a consistent **5-file structure**:

```
Feature/
├── FeatureView.swift          # SwiftUI view (UI only)
├── FeatureViewModel.swift     # View state & presentation logic
├── FeatureUseCase.swift       # Business logic (accesses managers)
├── FeatureBuilder.swift       # Dependency injection & view construction
└── FeatureRouter.swift        # Navigation (optional)
```

### Data Flow

```
User Action → View → ViewModel → UseCase → Manager → Service → External API
                ↓         ↓          ↓         ↓         ↓
            State Update ← Presentation ← Business Logic ← Response
```

## 📦 What Each File Does

### 1. **FeatureView.swift**
- **Pure SwiftUI UI** - No business logic
- Observes `@State var viewModel`
- Calls ViewModel methods on user actions
- Includes `#Preview` for development

### 2. **FeatureViewModel.swift**
- **`@Observable @MainActor class`**
- Holds UI state and presentation logic
- Communicates with UseCase for business logic
- Uses Router for navigation
- Contains `Event` enum for analytics tracking

### 3. **FeatureUseCase.swift**
- **Protocol-based business logic**
- Resolves dependencies from `DependencyContainer`
- Accesses managers (AIManager, ChatManager, etc.)
- No UI concerns - pure business logic

### 4. **FeatureBuilder.swift**
- **`@Observable @MainActor final class`**
- Receives `DependencyContainer` in init
- Creates and wires up the entire feature module
- Single method: `buildFeatureView(router: Router) -> some View`

### 5. **FeatureRouter.swift**
- **Protocol + implementation**
- Handles all navigation for the feature
- Extends `CoreRouter` for shared navigation
- Optional - can be minimal if no navigation needed

## 🚀 How to Use This Template

### Step 1: In Xcode
1. Right-click on the `AIChat/Core/` folder
2. Select **New File...**
3. Scroll to **Custom Templates** section
4. Select **MVVMTemplate**
5. Click **Next**

### Step 2: Fill in the Template Form
- **Module Name**: Your feature name in PascalCase (e.g., `UserProfile`, `Settings`, `About`)
- **camelCased Module Name**: Same name in camelCase (e.g., `userProfile`, `settings`, `about`)
- **Core Router Name**: Keep as `Core` (unless you have a custom router)

### Step 3: After Generation
1. **Review generated files** - All 5 files will be created in a new folder
2. **Add to Xcode project** - Drag the folder into Xcode if needed
3. **Implement your feature**:
   - Add UI to `FeatureView.swift`
   - Add business logic to `FeatureUseCase.swift`
   - Add presentation logic to `FeatureViewModel.swift`
   - Add navigation methods to `FeatureRouter.swift` if needed
4. **Register dependencies** in `AIChat/App/Dependencies.swift` if you create new managers

## ✅ Key Principles

### DO
- ✅ Use `DependencyContainer` to resolve all dependencies
- ✅ Follow protocol-based design for all services
- ✅ Keep View logic separate from business logic
- ✅ Use `@Observable` for ViewModels (not `ObservableObject`)
- ✅ Mark all UI classes with `@MainActor`
- ✅ Track user actions with the `Event` enum

### DON'T
- ❌ Use force unwrapping (`!`) - SwiftLint will error
- ❌ Use `try!` - SwiftLint will error
- ❌ Create service instances directly - always resolve from container
- ❌ Mix view logic with business logic
- ❌ Bypass the Builder pattern

## 📝 Example: Creating a "UserProfile" Feature

1. Use template with:
   - Module Name: `UserProfile`
   - camelCased Name: `userProfile`
   - Core Router Name: `Core`

2. Generated files:
   - `UserProfileView.swift`
   - `UserProfileViewModel.swift`
   - `UserProfileUseCase.swift`
   - `UserProfileBuilder.swift`
   - `UserProfileRouter.swift`

3. Implement your feature:
   ```swift
   // In UserProfileUseCase.swift
   private let userManager: UserManager?

   init(container: DependencyContainer) {
       self.userManager = container.resolve(UserManager.self)
       self.logManager = container.resolve(LogManager.self)
   }

   func fetchUserProfile() async throws -> User {
       try await userManager?.getCurrentUser() ?? User()
   }
   ```

4. Use in your app:
   ```swift
   let builder = UserProfileBuilder(container: container)
   let view = builder.buildUserProfileView(router: router)
   ```

## 🔍 Verification

To verify your feature matches the project pattern:

```bash
# Check file structure
ls AIChat/Core/YourFeature/

# Should output:
# YourFeatureView.swift
# YourFeatureViewModel.swift
# YourFeatureUseCase.swift
# YourFeatureBuilder.swift
# YourFeatureRouter.swift
```

## 📚 Related Documentation

- **CLAUDE.md**: Full architecture and development guidelines
- **Dependencies.swift**: Central dependency configuration
- **DependencyContainer.swift**: Service locator implementation

## 🎯 Template Maintenance

This template is based on the **About** feature, which serves as the reference implementation. If you update the architecture pattern, update:
1. This template
2. The About feature (reference implementation)
3. CLAUDE.md documentation
