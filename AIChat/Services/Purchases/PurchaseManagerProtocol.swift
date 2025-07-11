//
//  PurchaseManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.07.2025.
//

import Foundation

protocol PurchaseManagerProtocol: Sendable {
    func getProducts(productIds: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement]
}
