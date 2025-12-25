//
//  NewsFeedBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import SwiftUI
import SUIRouting

/// Builder for constructing NewsFeed feature views with proper dependency injection.
///
/// Architectural Pattern:
/// - Follows Builder Pattern for view construction
/// - Uses DependencyContainer (service locator) for dependency resolution
/// - Creates Interactors directly, which internally resolve their own dependencies
/// - Provides nested builders to routers for child view navigation
@MainActor
@Observable
final class NewsFeedBuilder {

    let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildNewsFeedView(router: Router) -> some View {
        return NewsFeedView(
            presenter: NewsFeedPresenter(
                // Interactor handles its own dependency resolution from container
                // This keeps builder logic simple while maintaining testability
                newsFeedInteractor: NewsFeedInteractor(container: container),
                router: NewsFeedRouter(
                    router: router,
                    // Nested builder enables router to construct child views for navigation
                    newsDetailsBuilder: NewsDetailsBuilder(container: container)
                )
            )
        )
    }
}
