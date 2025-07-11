//
//  StoreKitPurchaseService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import Foundation
import StoreKit

struct StoreKitPurchaseService {}

extension StoreKitPurchaseService: PurchaseServiceProtocol {
    
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadValue {
                await transaction.finish()
                
                let entitlements = await getUserEntitlements()
                await onTransactionUpdated(entitlements)
            }
        }
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        var activeTransactions: [PurchasedEntitlement] = []
        
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            
            switch verificationResult {
            case .verified(let transaction):
                let isActive: Bool
                if let expirationDate = transaction.expirationDate {
                    isActive = expirationDate >= Date.now
                } else {
                    isActive = transaction.revocationDate == nil
                }
                
                activeTransactions
                    .append(
                        PurchasedEntitlement(
                            id: transaction.productID,
                            productId: transaction.productID,
                            expirationDate: transaction.expirationDate,
                            isActive: isActive,
                            originalPurchaseDate: transaction.originalPurchaseDate,
                            latestPurchaseDate: transaction.purchaseDate,
                            ownershipType: EntitlementOwnershipOption(
                                type: transaction.ownershipType
                            ),
                            isSandbox: transaction.environment == .sandbox,
                            isVerified: true
                        )
                    )
            case .unverified:
                break
            @unknown default:
                break
            }
        }
        
        return activeTransactions
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        let products = try await Product.products(for: productIds)
        return products.compactMap({ AnyProduct(storeKitProduct: $0) })
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await AppStore.sync()
        return await getUserEntitlements()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        let products = try await Product.products(for: [productId])
        
        guard let product = products.first else {
            throw Error.productNotFound
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            let transaction = try verificationResult.payloadValue
            await transaction.finish()
            
            return await getUserEntitlements()
        case .userCancelled:
            throw Error.userCancelledPurchase
        default:
            throw Error.failedToPurchase
        }
    }
    
    enum Error: LocalizedError {
        case productNotFound, userCancelledPurchase, failedToPurchase
    }
}
