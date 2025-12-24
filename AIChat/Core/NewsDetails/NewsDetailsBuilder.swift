//
//  NewsDetailsBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
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
            presenter: NewsDetailsPresenter(
                article: article,
                newsDetailsInteractor: NewsDetailsInteractor(container: container),
                router: NewsDetailsRouter(router: router)
            )
        )
    }
}
