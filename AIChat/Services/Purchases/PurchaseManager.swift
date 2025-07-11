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

extension PurchaseManager: PurchaseManagerProtocol {
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        logManager?.trackEvent(event: Event.getProductsStart)
        
        do {
            let products = try await service.getProducts(productIds: productIds)
            logManager?.trackEvent(event: Event.getProductsSuccess(products: products))
            return products
        } catch {
            logManager?.trackEvent(event: Event.getProductsFail(error: error))
            throw error
        }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.restorePurchaseStart)
        
        do {
            let entitlements = try await service.restorePurchase()
            logManager?.trackEvent(event: Event.restorePurchaseSuccess(entitlements: entitlements))
            updateActiveEntitlements(entitlements)
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.restorePurchaseFail(error: error))
            throw error
        }
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.purchaseStart)
        
        do {
            let entitlements = try await service.purchaseProduct(productId: productId)
            logManager?.trackEvent(event: Event.purchaseSuccess(entitlements: entitlements))
            updateActiveEntitlements(entitlements)
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.purchaseFail(error: error))
            throw error
        }
    }
}

private extension PurchaseManager {
    
    enum Event: LoggableEvent {
        case purchaseStart
        case purchaseSuccess(entitlements: [PurchasedEntitlement])
        case purchaseFail(error: Error)
        case restorePurchaseStart
        case restorePurchaseSuccess(entitlements: [PurchasedEntitlement])
        case restorePurchaseFail(error: Error)
        case getProductsStart
        case getProductsSuccess(products: [AnyProduct])
        case getProductsFail(error: Error)
        
        var eventName: String {
            switch self {
            case .purchaseStart:            return "PurMan_Purchase_Start"
            case .purchaseSuccess:          return "PurMan_Purchase_Success"
            case .purchaseFail:             return "PurMan_Purchase_Fail"
            case .restorePurchaseStart:     return "PurMan_Restore_Start"
            case .restorePurchaseSuccess:   return "PurMan_Restore_Success"
            case .restorePurchaseFail:      return "PurMan_Restore_Fail"
            case .getProductsStart:         return "PurMan_GetProducts_Start"
            case .getProductsSuccess:       return "PurMan_GetProducts_Success"
            case .getProductsFail:          return "PurMan_GetProducts_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseSuccess(entitlements: let entitlements),
                    .restorePurchaseSuccess(entitlements: let entitlements):
                return entitlements.eventParameters
            case .getProductsSuccess(products: let products):
                return products.eventParameters
            case .purchaseFail(error: let error),
                    .getProductsFail(error: let error),
                    .restorePurchaseFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail, .getProductsFail, .restorePurchaseFail:
                return .severe
            default:
                return .analytic
            }
        }
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

