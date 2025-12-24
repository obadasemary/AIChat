//
//  DevSettingsBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class DevSettingsBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildDevSettingsView(router: Router) -> some View {
        DevSettingsView(
            presenter: DevSettingsPresenter(
                devSettingsInteractor: DevSettingsInteractor(container: container),
                router: DevSettingsRouter(router: router)
            )
        )
    }
}
