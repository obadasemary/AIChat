//
//  AppBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//


import SwiftUI

@Observable
@MainActor
final class AppBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildAppView() -> some View {
        AppView(
            viewModel: AppViewModel(
                appViewUseCase: AppViewUseCase(
                    container: container
                )
            )
        )
    }
}