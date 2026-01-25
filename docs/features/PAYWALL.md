# Paywall Feature

The Paywall feature manages subscription offerings and in-app purchases.

## Overview

The Paywall module displays subscription options, handles purchase flows, and manages premium feature access using StoreKit 2.

## Architecture

```
PaywallView
    ↓
PaywallViewModel
    ↓
PaywallUseCase
    ↓
├── PurchaseManager (StoreKit)
└── LogManager (analytics)
```

## Files

| File | Purpose |
|------|---------|
| `PaywallView.swift` | Main paywall view |
| `PaywallViewModel.swift` | View state and purchase handling |
| `PaywallUseCase.swift` | Business logic |
| `PaywallBuilder.swift` | Dependency injection |
| `PaywallRouter.swift` | Navigation handling |
| `PaywallConfiguration.swift` | Paywall configuration |
| `PaywallModels.swift` | Data models |

### Paywall Variants

| File | Purpose |
|------|---------|
| `CustomPaywallView.swift` | Custom designed paywall |
| `StoreKitPaywallView.swift` | Native StoreKit paywall |

## Key Features

### Subscription Display
- Product descriptions
- Pricing information
- Trial period details
- Feature comparisons

### Purchase Flow
- StoreKit 2 integration
- Purchase confirmation
- Error handling
- Receipt validation

### Restore Purchases
- Restore previous purchases
- Handle family sharing
- Verify entitlements

## Usage

### Building the Paywall View

```swift
@Environment(PaywallBuilder.self) var paywallBuilder

// Display paywall
paywallBuilder.buildPaywallView()
```

### Showing Paywall

```swift
// In any feature that requires premium
if !purchaseManager.isPremium {
    router.showPaywallView()
    return
}
```

## Subscription Products

### Configuration
```swift
struct PaywallConfiguration {
    let products: [AnyProduct]
    let features: [PaywallFeature]
    let headerTitle: String
    let ctaText: String
}
```

### Product Models
```swift
struct AnyProduct: Identifiable {
    let id: String
    let displayName: String
    let displayPrice: String
    let description: String
    let subscription: SubscriptionInfo?
}
```

## StoreKit 2 Integration

### Fetching Products
```swift
// In PurchaseManager
func fetchProducts() async throws -> [Product] {
    try await Product.products(for: productIds)
}
```

### Making Purchases
```swift
func purchase(_ product: Product) async throws -> Transaction? {
    let result = try await product.purchase()

    switch result {
    case .success(let verification):
        let transaction = try checkVerified(verification)
        await transaction.finish()
        return transaction
    case .userCancelled, .pending:
        return nil
    @unknown default:
        return nil
    }
}
```

### Checking Entitlements
```swift
func checkPremiumStatus() async -> Bool {
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result {
            if transaction.productID == premiumProductId {
                return true
            }
        }
    }
    return false
}
```

## Data Models

### EntitlementOption
```swift
struct EntitlementOption {
    let productId: String
    let title: String
    let duration: SubscriptionDuration
}
```

### PurchasedEntitlement
```swift
struct PurchasedEntitlement {
    let productId: String
    let purchaseDate: Date
    let expirationDate: Date?
    let isActive: Bool
}
```

## Premium Features

Features gated behind premium:
- Unlimited chat messages
- Priority AI responses
- Custom avatar creation
- Ad-free experience
- Exclusive avatars

## Dependencies

- **PurchaseManager**: StoreKit operations
- **LogManager**: Analytics tracking

## Error Handling

| Error | Handling |
|-------|----------|
| Products unavailable | Show error, allow retry |
| Purchase failed | Display error message |
| User cancelled | Dismiss paywall |
| Verification failed | Show support contact |
| Network error | Indicate offline mode |

## Testing

### Sandbox Testing
1. Create sandbox tester in App Store Connect
2. Sign out of App Store on device
3. Attempt purchase in app
4. Sign in with sandbox account

### Mock Service
```swift
// In Dependencies.swift for .mock configuration
purchaseManager = PurchaseManager(
    service: MockPurchaseService(),
    logManager: logManager
)
```

## Related Documentation

- [Purchase Service](../services/PURCHASE_SERVICE.md)
- [Chat Feature](./CHAT.md) (premium gating example)
