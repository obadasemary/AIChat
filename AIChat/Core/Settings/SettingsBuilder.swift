//
//  SettingsBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI
import SUIRouting

/// Builder for constructing Settings feature views with proper dependency injection.
///
/// Architectural Pattern:
/// - Follows Builder Pattern for view construction
/// - Uses DependencyContainer (service locator) for dependency resolution
/// - Creates UseCases directly, which internally resolve their own dependencies
/// - Provides nested builders to routers for child view navigation
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
                // UseCase handles its own dependency resolution from container
                // This keeps builder logic simple while maintaining testability
                settingsUseCase: SettingsUseCase(container: container),
                router: SettingsRouter(
                    router: router,
                    // Multiple nested builders enable navigation to different child views
                    createAccountBuilder: CreateAccountBuilder(
                        container: container
                    ),
                    aboutBuilder: AboutBuilder(
                        container: container
                    ),
                    adminBuilder: AdminBuilder(
                        container: container
                    ),
                    newsFeedBuilder: NewsFeedBuilder(
                        container: container
                    ),
                    bookmarksBuilder: BookmarksBuilder(
                        container: container
                    )
                ),
                onSignedIn: onSignedIn
            )
        )
    }
}
