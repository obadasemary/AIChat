# MVVM Template - Quick Reference Card

## 🎯 5-Second Summary
Every feature = 5 files: View, ViewModel, UseCase, Builder, Router

## 🚀 Create New Feature (30 seconds)
1. Right-click `AIChat/Core/` in Xcode
2. New File → Custom Templates → MVVMTemplate
3. Enter feature name (e.g., "Notifications")
4. Enter camelCase name (e.g., "notifications")
5. Click Create

## 📁 File Structure
```
YourFeature/
├── YourFeatureView.swift       # UI
├── YourFeatureViewModel.swift  # State
├── YourFeatureUseCase.swift    # Logic
├── YourFeatureBuilder.swift    # DI
└── YourFeatureRouter.swift     # Nav
```

## 💡 Common Tasks

### Add Business Logic
**File**: `YourFeatureUseCase.swift`
```swift
init(container: DependencyContainer) {
    self.manager = container.resolve(Manager.self)
}

func fetchData() async throws -> Data {
    try await manager?.getData() ?? []
}
```

### Add UI State
**File**: `YourFeatureViewModel.swift`
```swift
@Observable
@MainActor
class YourFeatureViewModel {
    var items: [Item] = []
    var isLoading = false

    func loadData() async {
        isLoading = true
        items = try await useCase.fetchData()
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

## ✅ Checklist Before Committing
- [ ] All 5 files present
- [ ] No force unwrap (`!`)
- [ ] No force try (`try!`)
- [ ] Dependencies resolved from container
- [ ] Analytics events added
- [ ] Run: `./verify-architecture.sh`
- [ ] Run: `swiftlint lint`

## 🔍 Verify Your Feature
```bash
./verify-architecture.sh
```

## 📚 Documentation
- `TEMPLATE_SETUP.md` - Full guide
- `ARCHITECTURE_DIAGRAM.md` - Visual guide
- `CLAUDE.md` - Project guidelines
- Template `README.md` - Template details

## 🚨 Common Mistakes

| ❌ Don't | ✅ Do |
|---------|------|
| `let x = manager!` | `guard let manager else { return }` |
| `try! service.call()` | `try await service.call()` |
| `let x = Manager()` | `container.resolve(Manager.self)` |
| Mix View & Logic | Keep UseCase separate |
| Skip protocols | Always use protocols |
| Forget @MainActor | Add to UI classes |

## 🎓 Architecture Cheat Sheet

**View** → Displays UI
**ViewModel** → Manages state
**UseCase** → Business logic
**Builder** → Wires it up
**Router** → Navigation

**Data Flow**: View → ViewModel → UseCase → Manager → Service

**Dependency**: Always use `container.resolve(Type.self)`

## 🔗 Quick Links

### Template Location
```
~/Library/Developer/Xcode/Templates/CustomTemplates/MVVMTemplate.xctemplate/
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

## 🎯 Pro Tips

1. **Start with UseCase** - Define business logic first
2. **Use protocols** - Easy to mock for testing
3. **Keep Views simple** - Delegate to ViewModel
4. **One concern per file** - Don't mix responsibilities
5. **Check the reference** - Look at About feature when stuck

---

**Need help?** Check `TEMPLATE_SETUP.md` for detailed guide!
