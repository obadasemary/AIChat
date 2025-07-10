//
//  PurchaseManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 09.07.2025.
//

import Foundation

@MainActor
@Observable
class PurchaseManager {
    
    private let service: PurchaseServiceProtocol
    private let logManager: LogManagerProtocol?
    
    private(set) var entitlements: [PurchasedEntitlement] = []
    
    init(
        service: PurchaseServiceProtocol,
        logManager: LogManagerProtocol? = nil
    ) {
        self.service = service
        self.logManager = logManager
        self.configure()
    }
}

private extension PurchaseManager {
    
    func configure() {
        Task {
            let entitlements = await service.getUserEntitlements()
            updateActiveEntitlements(entitlements)
        }
        Task {
            await service.listenForTransactions { entitlements in
                await updateActiveEntitlements(entitlements)
            }
        }
    }
    
    func updateActiveEntitlements(_ newEntitlements: [PurchasedEntitlement]) {
        self.entitlements = newEntitlements
            .sortedByKeyPath(keyPath: \.expirationDateCalc, ascending: false)
        logManager?
            .addUserProperties(
                dict: newEntitlements.eventParameters,
                isHighPriority: false
            )
    }
}

