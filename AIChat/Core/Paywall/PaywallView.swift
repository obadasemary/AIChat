//
//  PaywallView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @State var presenter: PaywallPresenter
    
    var body: some View {
        Group {
            switch presenter.option {
            case .custom:
                ZStack {
                    if presenter.products.isEmpty {
                        ProgressView()
                    } else {
                        CustomPaywallView(
                            products: presenter.products,
                            onBackButtonPressed: {
                                presenter.onBackButtonPressed()
                            },
                            onRestorePurchasePressed: {
                                presenter.onRestorePurchasePressed()
                            },
                            onPurchaseProductPressed: { product in
                                presenter
                                    .onPurchaseProductPressed(product: product)
                            }
                        )
                    }
                }
            case .storeKit:
                StoreKitPaywallView(
                    productIds: presenter.productIds,
                    onInAppPurchaseStart: presenter.onPurchaseStart,
                    onInAppPurchaseCompletion: { (product, result) in
                        presenter
                            .onPurchaseComplete(
                                product: product,
                                result: result
                            )
                    }
                )
            }
        }
        .screenAppearAnalytics(name: "Paywall")
        .task {
            await presenter.onLoadProducts()
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let paywallBuilder = PaywallBuilder(container: container)
    
    return RouterView { router in
        paywallBuilder.buildPaywallView(router: router)
    }
    .previewEnvironment()
}
