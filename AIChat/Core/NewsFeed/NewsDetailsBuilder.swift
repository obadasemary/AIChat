//
//  NewsDetailsBuilder.swift
//  AIChat
//
//  Created by Claude Code on 12.12.2025.
//

import SwiftUI
import SUIRouting

@Observable
final class NewsDetailsBuilder {

    // MARK: - Properties
    let container: DependencyContainer

    // MARK: - Initialization
    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Builder Methods
    @MainActor
    func buildNewsDetailsView(router: Router, article: NewsArticle) -> some View {
        NewsDetailsView(
            viewModel: NewsDetailsViewModel(
                article: article,
                newsDetailsUseCase: NewsDetailsUseCase(container: container),
                router: NewsDetailsRouter(router: router)
            )
        )
    }
}
