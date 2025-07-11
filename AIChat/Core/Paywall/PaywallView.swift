//
//  PaywallView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss

    @State private var products: [AnyProduct] = []
    @State private var productIds: [String] = EntitlementOption.allProductIds
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        ZStack {
            if products.isEmpty {
                ProgressView()
            } else {
                CustomPaywallView(
                    products: products,
                    onBackButtonPressed: onBackButtonPressed,
                    onRestorePurchasePressed: onRestorePurchasePressed,
                    onPurchaseProductPressed: onPurchaseProductPressed
                )
            }
        }
//        StoreKitPaywallView(
//            productIds: productIds,
//            onInAppPurchaseStart: onPurchaseStart,
//            onInAppPurchaseCompletion: onPurchaseComplete
//        )
        .screenAppearAnalytics(name: "Paywall")
        .showCustomAlert(alert: $showAlert)
        .task {
            await onLoadProducts()
        }
    }
}

// MARK: - Action

private extension PaywallView {
    
    private func onLoadProducts() async {
        do {
            products = try await purchaseManager.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onRestorePurchasePressed() {
        logManager.trackEvent(event: Event.restorePurchaseStart)

        Task {
            do {
                let entitlements = try await purchaseManager.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onPurchaseProductPressed(product: AnyProduct) {
        logManager.trackEvent(event: Event.purchaseStart(product: product))

        Task {
            do {
                let entitlements = try await purchaseManager.purchaseProduct(productId: product.id)
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))

                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                logManager.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
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
        case loadProductsStart
        case restorePurchaseStart
        case backButtonPressed
        
        var eventName: String {
            switch self {
            case .purchaseStart: "Paywall_Purchase_Start"
            case .purchaseSuccess: "Paywall_Purchase_Success"
            case .purchasePending: "Paywall_Purchase_Pending"
            case .purchaseCanceled: "Paywall_Purchase_Canceled"
            case .purchaseUnknown: "Paywall_Purchase_Unknown"
            case .purchaseFail: "Paywall_Purchase_Fail"
            case .loadProductsStart: "Paywall_Load_Start"
            case .restorePurchaseStart: "Paywall_Restore_Start"
            case .backButtonPressed: "Paywall_BackButton_Pressed"
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
            default:
                nil
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
