//
//  NewFeatureBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class NewFeatureBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildNewFeatureView(router: Router) -> some View {
        NewFeatureView(
            viewModel: NewFeatureViewModel(
                ___VARIABLE_camelCasedProductName:identifier___UseCase: NewFeatureUseCase(container: container),
                router: NewFeatureRouter(router: router)
            )
        )
    }
}
