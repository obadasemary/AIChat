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
    
    @Environment(\.dismiss) private var dismiss
    let option: PaywallOptional = .custom
    
    var body: some View {
        Group {
            switch option {
            case .custom:
                ZStack {
                    if viewModel.products.isEmpty {
                        ProgressView()
                    } else {
                        CustomPaywallView(
                            products: viewModel.products,
                            onBackButtonPressed: {
                                viewModel.onBackButtonPressed {
                                    dismiss()
                                }
                            },
                            onRestorePurchasePressed: {
                                viewModel.onRestorePurchasePressed {
                                    dismiss()
                                }
                            },
                            onPurchaseProductPressed: { product in
                                viewModel.onPurchaseProductPressed(product: product) {
                                    dismiss()
                                }
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
                            ) {
                                dismiss()
                            }
                    }
                )
            }
        }
        .screenAppearAnalytics(name: "Paywall")
        .showCustomAlert(alert: $viewModel.showAlert)
        .task {
            await viewModel.onLoadProducts()
        }
    }
}

enum PaywallOptional {
    case custom
    case storeKit
}

#Preview {
    let container = DevPreview.shared.container
    let paywallBuilder = PaywallBuilder(container: container)
    
    return paywallBuilder.buildPaywallView()
        .previewEnvironment()
}
