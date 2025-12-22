//
//  AboutBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.12.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class AboutBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildAboutView(router: Router) -> some View {
        AboutView(
            viewModel: AboutViewModel(
                aboutUseCase: AboutUseCase(container: container),
                router: AboutRouter(router: router)
            )
        )
    }
}
