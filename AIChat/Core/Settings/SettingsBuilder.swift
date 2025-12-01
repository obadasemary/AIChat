//
//  SettingsBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class SettingsBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildSettingsView(
        router: Router,
        onSignedIn: @escaping () -> Void = {}
    ) -> some View {
        SettingsView(
            viewModel: SettingsViewModel(
                settingsUseCase: SettingsUseCase(container: container),
                router: SettingsRouter(
                    router: router,
                    createAccountBuilder: CreateAccountBuilder(
                        container: container
                    ),
                    aboutBuilder: AboutBuilder(
                        container: container
                    )
                ),
                onSignedIn: onSignedIn
            )
        )
    }
}
