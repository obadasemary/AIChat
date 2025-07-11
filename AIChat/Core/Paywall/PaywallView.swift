//
//  PaywallView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        StoreKitPaywallView(
            onInAppPurchaseStart: onPurchaseStart,
            onInAppPurchaseCompletion: onPurchaseComplete
        )
        .screenAppearAnalytics(name: "Paywall")
    }
}

// MARK: - Action

private extension PaywallView {
    
    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        logManager.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    func onPurchaseComplete(
        product: StoreKit.Product,
        result: Result<Product.PurchaseResult, any Error>
    ) {
        let product = AnyProduct(storeKitProduct: product)
        
        switch result {
        case .success(let vlaue):
            switch vlaue {
            case .success:
                logManager.trackEvent(
                    event: Event.purchaseSuccess(product: product)
                )
                dismiss()
            case .pending:
                logManager.trackEvent(
                    event: Event.purchasePending(product: product)
                )
            case .userCancelled:
                logManager.trackEvent(
                    event: Event.purchaseCanceled(product: product)
                )
            default:
                logManager.trackEvent(
                    event: Event.purchaseUnknown(product: product)
                )
            }
        case .failure(let error):
            logManager.trackEvent(
                event: Event.purchaseFail(error: error)
            )
        }
    }
}

// MARK: - Event

private extension PaywallView {
    
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseCanceled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        
        var eventName: String {
            switch self {
            case .purchaseStart: "Paywall_Purchase_Start"
            case .purchaseSuccess: "Paywall_Purchase_Success"
            case .purchasePending: "Paywall_Purchase_Pending"
            case .purchaseCanceled: "Paywall_Purchase_Canceled"
            case .purchaseUnknown: "Paywall_Purchase_Unknown"
            case .purchaseFail: "Paywall_Purchase_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .purchaseStart(product: let product),
                    .purchaseSuccess(product: let product),
                    .purchasePending(product: let product),
                    .purchaseCanceled(product: let product),
                    .purchaseUnknown(product: let product):
                product.eventParameters
            case .purchaseFail(error: let error):
                error.eventParameters
//            default:
//                nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    PaywallView()
        .previewEnvironment()
}
