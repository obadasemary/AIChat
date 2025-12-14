//
//  BookmarksRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import SwiftUI

@MainActor
protocol BookmarksRouterProtocol {
    func showNewsDetailsView(article: NewsArticle)
}

@MainActor
@Observable
final class BookmarksRouter: BookmarksRouterProtocol {

    private let router: Router
    private let newsDetailsBuilder: NewsDetailsBuilder

    init(
        router: Router,
        newsDetailsBuilder: NewsDetailsBuilder
    ) {
        self.router = router
        self.newsDetailsBuilder = newsDetailsBuilder
    }

    func showNewsDetailsView(article: NewsArticle) {
        router.push(
            newsDetailsBuilder.buildNewsDetailsView(
                router: router,
                article: article
            )
        )
    }
}
