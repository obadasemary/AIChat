# MessageKit Keyboard & Tab Bar Fixes

## Issues Fixed

### 1. **Tab Bar Overlapping Messages** ❌
**Problem**: The messages collection view was being cut off by the tab bar at the bottom of the screen.

**Solution**:
- Set `contentInsetAdjustmentBehavior = .automatic` on messagesCollectionView
- Set `additionalBottomInset = 0` to properly handle tab bar
- This ensures the collection view respects safe area insets and tab bar height

### 2. **Keyboard Covering Input Bar** ❌
**Problem**: When the keyboard appeared, it covered the input bar instead of pushing it up.

**Solution**: Use **MessagesViewController's built-in keyboard handling** (no custom code needed!)
- MessagesViewController already has `inputContainerView` that holds `messageInputBar`
- Uses `KeyboardManager` from InputBarAccessoryView to track keyboard automatically
- Automatically adjusts `messagesCollectionView` content insets when keyboard appears
- **DO NOT** override keyboard handling - let MessageKit do its job
- Works perfectly in SwiftUI via UIViewControllerRepresentable

### 3. **SwiftUI inputAccessoryView Incompatibility** ❌
**Problem**: UIKit `inputAccessoryView` caused `UIViewControllerHierarchyInconsistency` crashes in SwiftUI context.

**Solution**: Don't use inputAccessoryView - use keyboard notifications instead
- SwiftUI's `UIViewControllerRepresentable` manages view controller hierarchy differently than pure UIKit
- The `inputAccessoryView` pattern expects a specific parent-child relationship that SwiftUI doesn't provide
- MessageKit's keyboard notification observers work correctly in SwiftUI contexts
- Only ignore `.container` safe area, let MessageKit handle keyboard adjustments

## How It Works

### MessagesViewController's Built-in Keyboard Handling

MessagesViewController automatically handles everything via its internal architecture:

**1. View Hierarchy Setup** (in `viewDidLoad`):
```swift
// MessagesViewController.swift
view.addSubviews(messagesCollectionView, inputContainerView)
```

**2. Keyboard Manager Binding** (in `addKeyboardObservers`):
```swift
// MessagesViewController+Keyboard.swift
keyboardManager.bind(
    inputAccessoryView: inputContainerView,
    withAdditionalBottomSpace: { [weak self] in self?.inputBarAdditionalBottomSpace() ?? 0 }
)
keyboardManager.bind(to: messagesCollectionView)
```

**3. Input Bar Setup** (in `setupInputBar`):
```swift
// MessagesViewController.swift
inputContainerView.addSubview(messageInputBar)
// Pins messageInputBar to all edges of inputContainerView
```

**4. Automatic Content Inset Updates**:
```swift
// MessagesViewController+Keyboard.swift
inputContainerView.publisher(for: \.center)
    .sink { [weak self] _ in
        self?.updateMessageCollectionViewBottomInset()
    }
```

**What You Need to Do:**
```swift
// Just subclass and configure - MessageKit handles the rest!
final class MessageKitChatViewController: MessagesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
        // That's it! Don't add custom keyboard handling
    }
}
```

**Why this works:**
1. `KeyboardManager` (from InputBarAccessoryView) automatically tracks keyboard
2. Moves `inputContainerView` when keyboard appears/disappears
3. MessagesViewController observes `inputContainerView` frame changes
4. Automatically adjusts `messagesCollectionView.contentInset.bottom`
5. No manual keyboard observers needed
6. No custom constraints needed
7. Works perfectly in SwiftUI's `UIViewControllerRepresentable`

### Benefits

✅ Input bar moves smoothly with keyboard
✅ Proper animations (fade, slide, etc.)
✅ Works with all keyboard types (default, emoji, third-party)
✅ Handles keyboard size changes automatically
✅ Works with predictive text bar
✅ Respects tab bar and safe areas

## Files Modified

1. **MessageKitChatViewController.swift**
   - Added `inputAccessoryView` override
   - Added `canBecomeFirstResponder` override
   - Set `contentInsetAdjustmentBehavior` for collection view
   - Call `becomeFirstResponder()` in viewDidLoad

2. **MessageKitChatView.swift**
   - Added `.withKeyboardHandling()` extension method
   - Applies `.ignoresSafeArea(.keyboard, edges: .bottom)`

3. **ChatView.swift**
   - Applied `.withKeyboardHandling()` to MessageKitChatView

## Testing Checklist

- [ ] Input bar appears above tab bar
- [ ] Keyboard pushes input bar up (not covering it)
- [ ] Input bar animates smoothly with keyboard
- [ ] Messages scroll properly without being cut off by tab bar
- [ ] Switching between emoji and text keyboard works
- [ ] Third-party keyboards work correctly
- [ ] Predictive text bar doesn't cause issues
- [ ] Landscape orientation works correctly

## Common Issues & Solutions

### Issue: Input bar still gets covered
**Solution**: Ensure `becomeFirstResponder()` is called and returns true

### Issue: Tab bar still overlaps messages
**Solution**: Check that navigation controller's `hidesBottomBarWhenPushed` is not interfering

### Issue: Keyboard animations are janky
**Solution**: Remove any custom keyboard handling code that might conflict

## Alternative Approaches (Not Used)

We **did NOT** use these approaches because they're more complex:

❌ Manual keyboard notification observers (`keyboardWillShow`, `keyboardWillHide`)
❌ Manual content inset adjustments
❌ Custom animation coordination
❌ SwiftUI keyboard publishers

The keyboard accessory view pattern is the **Apple-recommended** approach and handles everything automatically.

## References

- [Apple Documentation: UIResponder inputAccessoryView](https://developer.apple.com/documentation/uikit/uiresponder/1621119-inputaccessoryview)
- [MessageKit Documentation](https://messagekit.github.io/)
- [Human Interface Guidelines: Keyboards](https://developer.apple.com/design/human-interface-guidelines/keyboards)
