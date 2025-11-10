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
class PaywallViewModel {

    private let paywallUseCase: PaywallUseCaseProtocol
    private let router: PaywallRouterProtocol

    private(set) var products: [AnyProduct] = []
    private(set) var productIds: [String] = EntitlementOption.allProductIds
    let option: PaywallOptional = PaywallConfiguration.shared.currentOption

    init(
        paywallUseCase: PaywallUseCaseProtocol,
        router: PaywallRouterProtocol
    ) {
        self.paywallUseCase = paywallUseCase
        self.router = router
    }
}

// MARK: - Action
extension PaywallViewModel {
    
    func onLoadProducts() async {
        do {
            products = try await paywallUseCase
                .getProducts(productIds: productIds)
        } catch {
            router.showAlert(error: error)
        }
    }
    
    func onBackButtonPressed() {
        paywallUseCase.trackEvent(event: Event.backButtonPressed)
        router.dismissScreen()
    }
    
    func onRestorePurchasePressed() {
        paywallUseCase.trackEvent(event: Event.restorePurchaseStart)

        Task { [weak self] in
            guard let self else { return }
            do {
                let entitlements = try await self.paywallUseCase.restorePurchase()

                if entitlements.hasActiveEntitlement {
                    self.router.dismissScreen()
                }
            } catch {
                self.router.showAlert(error: error)
            }
        }
    }
    
    func onPurchaseProductPressed(product: AnyProduct) {
        paywallUseCase.trackEvent(event: Event.purchaseStart(product: product))

        Task { [weak self] in
            guard let self else { return }
            do {
                let entitlements = try await self.paywallUseCase.purchaseProduct(productId: product.id)
                self.paywallUseCase.trackEvent(event: Event.purchaseSuccess(product: product))

                if entitlements.hasActiveEntitlement {
                    self.router.dismissScreen()
                }
            } catch {
                self.paywallUseCase.trackEvent(event: Event.purchaseFail(error: error))
                self.router.showAlert(error: error)
            }
        }
    }
    
    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        paywallUseCase.trackEvent(event: Event.purchaseStart(product: product))
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
                paywallUseCase.trackEvent(
                    event: Event.purchaseSuccess(product: product)
                )
                router.dismissScreen()
            case .pending:
                paywallUseCase.trackEvent(
                    event: Event.purchasePending(product: product)
                )
            case .userCancelled:
                paywallUseCase.trackEvent(
                    event: Event.purchaseCanceled(product: product)
                )
            default:
                paywallUseCase.trackEvent(
                    event: Event.purchaseUnknown(product: product)
                )
            }
        case .failure(let error):
            paywallUseCase.trackEvent(
                event: Event.purchaseFail(error: error)
            )
        }
    }
}

// MARK: - Event

private extension PaywallViewModel {
    
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
