//
//  PaywallView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.07.2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @State var viewModel: PaywallViewModel
    
    var body: some View {
        Group {
            switch viewModel.option {
            case .custom:
                ZStack {
                    if viewModel.products.isEmpty {
                        ProgressView()
                    } else {
                        CustomPaywallView(
                            products: viewModel.products,
                            onBackButtonPressed: {
                                viewModel.onBackButtonPressed()
                            },
                            onRestorePurchasePressed: {
                                viewModel.onRestorePurchasePressed()
                            },
                            onPurchaseProductPressed: { product in
                                viewModel
                                    .onPurchaseProductPressed(product: product)
                            }
                        )
                    }
                }
            case .storeKit:
                StoreKitPaywallView(
                    productIds: viewModel.productIds,
                    onInAppPurchaseStart: viewModel.onPurchaseStart,
                    onInAppPurchaseCompletion: { (product, result) in
                        viewModel
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
            await viewModel.onLoadProducts()
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
