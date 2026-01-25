# Purchase Service

The Purchase Service manages in-app purchases and subscriptions using StoreKit 2.

## Overview

The Purchase Service handles product fetching, purchase transactions, subscription management, and entitlement verification through Apple's StoreKit 2 framework.

## Architecture

```
PurchaseManager (Orchestration)
    ↓
PurchaseServiceProtocol
    ↓
├── StoreKitPurchaseService (Production)
└── MockPurchaseService (Testing)
```

## Files

| File | Path |
|------|------|
| `PurchaseManager.swift` | `Services/Purchases/PurchaseManager.swift` |
| `PurchaseManagerProtocol.swift` | `Services/Purchases/PurchaseManagerProtocol.swift` |

### Services
| File | Path |
|------|------|
| `PurchaseServiceProtocol.swift` | `Services/Purchases/Services/PurchaseServiceProtocol.swift` |
| `StoreKitPurchaseService.swift` | `Services/Purchases/Services/StoreKitPurchaseService.swift` |
| `MockPurchaseService.swift` | `Services/Purchases/Services/MockPurchaseService.swift` |

### Models
| File | Path |
|------|------|
| `AnyProduct.swift` | `Services/Purchases/Models/AnyProduct.swift` |
| `AnyProduct+StoreKit.swift` | `Services/Purchases/Models/AnyProduct+StoreKit.swift` |
| `EntitlementOption.swift` | `Services/Purchases/Models/EntitlementOption.swift` |
| `EntitlementOwnershipOption.swift` | `Services/Purchases/Models/EntitlementOwnershipOption.swift` |
| `PurchasedEntitlement.swift` | `Services/Purchases/Models/PurchasedEntitlement.swift` |

## Protocol Definition

### PurchaseManagerProtocol
```swift
protocol PurchaseManagerProtocol {
    var isPremium: Bool { get }
    var products: [AnyProduct] { get }
    var purchasedEntitlements: [PurchasedEntitlement] { get }

    func fetchProducts() async throws
    func purchase(_ product: AnyProduct) async throws -> Bool
    func restorePurchases() async throws
    func checkPremiumStatus() async -> Bool
}
```

## Usage

### Resolving from Container
```swift
let purchaseManager = container.resolve(PurchaseManager.self)
```

### Check Premium Status
```swift
if purchaseManager.isPremium {
    // User has premium access
} else {
    // Show paywall
}
```

### Fetch Products
```swift
try await purchaseManager.fetchProducts()
let products = purchaseManager.products
```

### Make Purchase
```swift
let success = try await purchaseManager.purchase(selectedProduct)
if success {
    // Purchase successful
}
```

### Restore Purchases
```swift
try await purchaseManager.restorePurchases()
```

## Data Models

### AnyProduct
```swift
struct AnyProduct: Identifiable {
    let id: String
    let displayName: String
    let displayPrice: String
    let description: String
    let subscription: SubscriptionInfo?

    var isSubscription: Bool {
        subscription != nil
    }
}
```

### PurchasedEntitlement
```swift
struct PurchasedEntitlement {
    let productId: String
    let purchaseDate: Date
    let expirationDate: Date?
    let isActive: Bool
    let ownershipType: EntitlementOwnershipOption
}
```

### EntitlementOption
```swift
enum EntitlementOption: String, CaseIterable {
    case weekly = "com.aichat.premium.weekly"
    case monthly = "com.aichat.premium.monthly"
    case yearly = "com.aichat.premium.yearly"
    case lifetime = "com.aichat.premium.lifetime"
}
```

## StoreKit 2 Integration

### Fetching Products
```swift
func fetchProducts() async throws {
    let productIds = EntitlementOption.allCases.map { $0.rawValue }
    let storeProducts = try await Product.products(for: productIds)
    products = storeProducts.map { AnyProduct(from: $0) }
}
```

### Making Purchases
```swift
func purchase(_ product: AnyProduct) async throws -> Bool {
    guard let storeProduct = storeProducts.first(where: { $0.id == product.id }) else {
        throw PurchaseError.productNotFound
    }

    let result = try await storeProduct.purchase()

    switch result {
    case .success(let verification):
        let transaction = try checkVerified(verification)
        await transaction.finish()
        await updatePremiumStatus()
        return true

    case .userCancelled:
        return false

    case .pending:
        return false

    @unknown default:
        return false
    }
}
```

### Checking Entitlements
```swift
func checkPremiumStatus() async -> Bool {
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result {
            if EntitlementOption.allCases.map({ $0.rawValue }).contains(transaction.productID) {
                if transaction.revocationDate == nil {
                    return true
                }
            }
        }
    }
    return false
}
```

### Transaction Listener
```swift
func listenForTransactions() -> Task<Void, Error> {
    Task.detached {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await self.updatePremiumStatus()
            }
        }
    }
}
```

## Build Configuration

### Development (.dev)
```swift
purchaseManager = PurchaseManager(
    service: StoreKitPurchaseService(),
    logManager: logManager
)
```

### Production (.prod)
```swift
purchaseManager = PurchaseManager(
    service: StoreKitPurchaseService(),
    logManager: logManager
)
```

### Mock (.mock)
```swift
purchaseManager = PurchaseManager(
    service: MockPurchaseService(),
    logManager: logManager
)
```

## Testing

### Sandbox Testing
1. Create sandbox tester in App Store Connect
2. Sign out of App Store on device
3. Launch app and attempt purchase
4. Sign in with sandbox credentials

### StoreKit Testing in Xcode
1. Create StoreKit Configuration file
2. Add products matching your identifiers
3. Select configuration in scheme
4. Test purchases without sandbox

## Error Handling

| Error | Description | Recovery |
|-------|-------------|----------|
| Products unavailable | Failed to fetch products | Retry fetch |
| Purchase failed | Transaction failed | Show error message |
| User cancelled | User cancelled purchase | Dismiss paywall |
| Verification failed | Receipt verification failed | Contact support |
| Not entitled | No active subscription | Show paywall |

## Analytics Events

| Event | Description |
|-------|-------------|
| `products_fetched` | Products loaded successfully |
| `purchase_started` | User initiated purchase |
| `purchase_completed` | Purchase successful |
| `purchase_cancelled` | User cancelled |
| `purchase_failed` | Purchase error |
| `restore_completed` | Restore successful |

## Related Documentation

- [Paywall Feature](../features/PAYWALL.md)
- [Chat Feature](../features/CHAT.md) (premium gating)
