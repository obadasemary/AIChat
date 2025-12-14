//
//  BookmarksRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol BookmarksRouterProtocol {
    func showNewsDetailsView(article: NewsArticle)
}

struct BookmarksRouter {
    let router: Router
    let newsDetailsBuilder: NewsDetailsBuilder
}

@MainActor
extension BookmarksRouter: BookmarksRouterProtocol {

    func showNewsDetailsView(article: NewsArticle) {
        router.showScreen(.push) { router in
            newsDetailsBuilder.buildNewsDetailsView(
                router: router,
                article: article
            )
        }
    }
}
