//
//  BookmarksBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import SwiftUI
import SUIRouting

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
        let bookmarksInteractor = BookmarksInteractor(container: container)
        let viewModel = BookmarksPresenter(
            bookmarksInteractor: bookmarksInteractor,
            router: bookmarksRouter
        )

        return BookmarksView(presenter: viewModel)
    }
}
