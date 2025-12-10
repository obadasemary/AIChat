//
//  NewsFeedBuilder.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import SwiftUI

@MainActor
@Observable
final class NewsFeedBuilder {

    let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildNewsFeedView() -> some View {
        NewsFeedView(
            viewModel: NewsFeedViewModel(
                newsFeedUseCase: NewsFeedUseCase(
                    container: container
                )
            )
        )
    }
}
