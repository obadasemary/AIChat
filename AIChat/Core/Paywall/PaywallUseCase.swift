//
//  PaywallUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol PaywallUseCaseProtocol {
    //    var paywallTest: PaywallTestOption { get }
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class PaywallUseCase {
    
    private let logManager: LogManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        guard let purchaseManager = container.resolve(PurchaseManager.self),
                let logManager = container.resolve(LogManager.self) else {
            fatalError("Required dependencies not registered in container")
        }
        self.logManager = logManager
        self.purchaseManager = purchaseManager
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
