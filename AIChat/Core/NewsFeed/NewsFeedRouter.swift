//
//  NewsFeedRouter.swift
//  AIChat
//
//  Created by Claude Code on 13.12.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol NewsFeedRouterProtocol {
    func showNewsDetailsView(article: NewsArticle)
}

@MainActor
struct NewsFeedRouter {
    let router: Router
    let newsDetailsBuilder: NewsDetailsBuilder
}

extension NewsFeedRouter: NewsFeedRouterProtocol {
    func showNewsDetailsView(article: NewsArticle) {
        router.showScreen(.push) { router in
            newsDetailsBuilder.buildNewsDetailsView(
                router: router,
                article: article
            )
        }
    }
}
