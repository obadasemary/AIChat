//
//  BookmarksBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import SwiftUI

@MainActor
@Observable
final class BookmarksBuilder {

    let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildBookmarksView(router: Router) -> some View {
        let newsDetailsBuilder = NewsDetailsBuilder(container: container)
        let bookmarksRouter = BookmarksRouter(
            router: router,
            newsDetailsBuilder: newsDetailsBuilder
        )
        let bookmarksUseCase = BookmarksUseCase(container: container)
        let viewModel = BookmarksViewModel(
            bookmarksUseCase: bookmarksUseCase,
            router: bookmarksRouter
        )

        return BookmarksView(viewModel: viewModel)
    }
}
