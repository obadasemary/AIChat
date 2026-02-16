# VIPER Template - Quick Reference Card

## 5-Second Summary
Every feature = 5 files: View, Presenter, Interactor, Builder, Router

## Create New Feature (30 seconds)
1. Right-click `AIChat/Core/` in Xcode
2. New File -> Custom Templates -> VIPERTemplate
3. Enter feature name (e.g., "Notifications")
4. Enter camelCase name (e.g., "notifications")
5. Click Create

## File Structure
```
YourFeature/
├── YourFeatureView.swift          # UI
├── YourFeaturePresenter.swift     # State & presentation
├── YourFeatureInteractor.swift    # Logic
├── YourFeatureBuilder.swift       # DI
└── YourFeatureRouter.swift        # Nav
```

## Common Tasks

### Add Business Logic
**File**: `YourFeatureInteractor.swift`
```swift
init(container: DependencyContainer) {
    self.manager = container.resolve(Manager.self)
}

func fetchData() async throws -> Data {
    try await manager?.getData() ?? []
}
```

### Add UI State
**File**: `YourFeaturePresenter.swift`
```swift
@Observable
@MainActor
class YourFeaturePresenter {
    var items: [Item] = []
    var isLoading = false

    func loadData() async {
        isLoading = true
        items = try await interactor.fetchData()
        isLoading = false
    }
}
```

### Add Navigation
**File**: `YourFeatureRouter.swift`
```swift
func navigateToDetail(item: Item) {
    let builder = DetailBuilder(container: container)
    router.push(builder.buildDetailView(router: router))
}
```

## Checklist Before Committing
- [ ] All 5 files present
- [ ] No force unwrap (`!`)
- [ ] No force try (`try!`)
- [ ] Dependencies resolved from container
- [ ] Analytics events added
- [ ] Run: `./verify-architecture.sh`
- [ ] Run: `swiftlint lint`

## Verify Your Feature
```bash
./verify-architecture.sh
```

## Documentation
- `TEMPLATE_SETUP.md` - Full guide
- `CLAUDE.md` - Project guidelines
- Template `README.md` - Template details

## Common Mistakes

| Don't | Do |
|-------|-----|
| `let x = manager!` | `guard let manager else { return }` |
| `try! service.call()` | `try await service.call()` |
| `let x = Manager()` | `container.resolve(Manager.self)` |
| Mix View & Logic | Keep Interactor separate |
| Skip protocols | Always use protocols |
| Forget @MainActor | Add to UI classes |

## Architecture Cheat Sheet

**View** -> Displays UI
**Presenter** -> Manages state & presentation logic
**Interactor** -> Business logic & data operations
**Builder** -> Wires it up via DI
**Router** -> Navigation

**Data Flow**: View -> Presenter -> Interactor -> Manager -> Service

**Dependency**: Always use `container.resolve(Type.self)`

## Quick Links

### Template Location
```
~/Library/Developer/Xcode/Templates/CustomTemplates/VIPERTemplate.xctemplate/
```

### Reference Feature
```
AIChat/Core/About/
```

### Verification Script
```
./verify-architecture.sh
```

### Lint Check
```
swiftlint lint
swiftlint lint --fix
```

## Pro Tips

1. **Start with Interactor** - Define business logic first
2. **Use protocols** - Easy to mock for testing
3. **Keep Views simple** - Delegate to Presenter
4. **One concern per file** - Don't mix responsibilities
5. **Check the reference** - Look at About feature when stuck

---

**Need help?** Check `TEMPLATE_SETUP.md` for detailed guide!
