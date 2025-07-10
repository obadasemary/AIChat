//
//  PurchaseServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import Foundation

protocol PurchaseServiceProtocol: Sendable {
    func listenForTransactions(
        onTransactionUpdated: @Sendable ([PurchasedEntitlement]) async -> Void
    ) async
    func getUserEntitlements() async -> [PurchasedEntitlement]
}
