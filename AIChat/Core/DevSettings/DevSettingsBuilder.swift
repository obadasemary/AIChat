//
//  DevSettingsBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class DevSettingsBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildDevSettingsView() -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(
                devSettingsUseCase: DevSettingsUseCase(container: container)
            )
        )
    }
}
