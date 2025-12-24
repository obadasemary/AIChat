//
//  PaywallViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation
import StoreKit

@Observable
@MainActor
class PaywallPresenter {
    
    private let paywallInteractor: PaywallInteractorProtocol
    private let router: PaywallRouterProtocol
    
    private(set) var products: [AnyProduct] = []
    private(set) var productIds: [String] = EntitlementOption.allProductIds
    let option: PaywallOptional = PaywallConfiguration.shared.currentOption
    
    init(
        paywallInteractor: PaywallInteractorProtocol,
        router: PaywallRouterProtocol
    ) {
        self.paywallInteractor = paywallInteractor
        self.router = router
    }
}

// MARK: - Action
extension PaywallPresenter {
    
    func onLoadProducts() async {
        do {
            products = try await paywallInteractor
                .getProducts(productIds: productIds)
        } catch {
            router.showAlert(error: error)
        }
    }
    
    func onBackButtonPressed() {
        paywallInteractor.trackEvent(event: Event.backButtonPressed)
        router.dismissScreen()
    }
    
    func onRestorePurchasePressed() {
        paywallInteractor.trackEvent(event: Event.restorePurchaseStart)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let entitlements = try await self.paywallInteractor.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    self.router.dismissScreen()
                }
            } catch {
                self.router.showAlert(error: error)
            }
        }
    }
    
    func onPurchaseProductPressed(product: AnyProduct) {
        paywallInteractor.trackEvent(event: Event.purchaseStart(product: product))
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let entitlements = try await self.paywallInteractor.purchaseProduct(productId: product.id)
                self.paywallInteractor.trackEvent(event: Event.purchaseSuccess(product: product))
                
                if entitlements.hasActiveEntitlement {
                    self.router.dismissScreen()
                }
            } catch {
                self.paywallInteractor.trackEvent(event: Event.purchaseFail(error: error))
                self.router.showAlert(error: error)
            }
        }
    }
    
    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        paywallInteractor.trackEvent(event: Event.purchaseStart(product: product))
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
                paywallInteractor.trackEvent(
                    event: Event.purchaseSuccess(product: product)
                )
                router.dismissScreen()
            case .pending:
                paywallInteractor.trackEvent(
                    event: Event.purchasePending(product: product)
                )
            case .userCancelled:
                paywallInteractor.trackEvent(
                    event: Event.purchaseCanceled(product: product)
                )
            default:
                paywallInteractor.trackEvent(
                    event: Event.purchaseUnknown(product: product)
                )
            }
        case .failure(let error):
            paywallInteractor.trackEvent(
                event: Event.purchaseFail(error: error)
            )
        }
    }
}

// MARK: - Event

private extension PaywallPresenter {
    
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
