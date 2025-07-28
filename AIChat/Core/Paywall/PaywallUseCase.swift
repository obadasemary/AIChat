//
//  PaywallUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class PaywallUseCase {
    
    private let logManager: LogManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
    }
}

extension PaywallUseCase: PaywallUseCaseProtocol {
    
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
