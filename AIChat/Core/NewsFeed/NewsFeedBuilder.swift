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
        // swiftlint:disable:next force_unwrapping
        let networkMonitor = container.resolve(NetworkMonitor.self)!

        return NewsFeedView(
            viewModel: NewsFeedViewModel(
                newsFeedUseCase: NewsFeedUseCase(
                    container: container
                ),
                networkMonitor: networkMonitor
            )
        )
    }
}
