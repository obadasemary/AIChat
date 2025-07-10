//
//  MockPurchaseService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import Foundation

struct MockPurchaseService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
}

extension MockPurchaseService: PurchaseServiceProtocol {
    
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async {
        await onTransactionUpdated(activeEntitlements)
    }

    func getUserEntitlements() async -> [PurchasedEntitlement] {
        activeEntitlements
    }
}
