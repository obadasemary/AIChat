//
//  NewsFeedBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import SwiftUI
import SUIRouting

@MainActor
@Observable
final class NewsFeedBuilder {

    let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildNewsFeedView(router: Router) -> some View {
        return NewsFeedView(
            viewModel: NewsFeedViewModel(
                newsFeedUseCase: NewsFeedUseCase(container: container),
                router: NewsFeedRouter(
                    router: router,
                    newsDetailsBuilder: NewsDetailsBuilder(container: container)
                )
            )
        )
    }
}
