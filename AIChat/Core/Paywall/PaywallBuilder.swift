//
//  PaywallBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class PaywallBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildPaywallView() -> some View {
        PaywallView(
            viewModel: PaywallViewModel(
                paywallUseCase: PaywallUseCase(container: container)
            )
        )
    }
}
