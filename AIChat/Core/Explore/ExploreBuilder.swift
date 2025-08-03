//
//  ExploreBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class ExploreBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildExploreView() -> some View {
        ExploreView(
            viewModel: ExploreViewModel(
                exploreUseCase: ExploreUseCase(container: container)
            )
        )
    }
}
