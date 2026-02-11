//
//  PaywallInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol PaywallInteractorProtocol {
    //    var paywallTest: PaywallTestOption { get }
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class PaywallInteractor {
    
    private let logManager: LogManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for PaywallInteractor")
        }
        guard let purchaseManager = container.resolve(PurchaseManager.self) else {
            preconditionFailure("Failed to resolve PurchaseManager for PaywallInteractor")
        }
        self.logManager = logManager
        self.purchaseManager = purchaseManager
    }
}

extension PaywallInteractor: PaywallInteractorProtocol {
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
