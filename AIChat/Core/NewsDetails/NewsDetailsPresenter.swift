//
//  NewsDetailsPresenter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation
import UIKit

@MainActor
@Observable
final class NewsDetailsPresenter {

    // MARK: - Properties
    let article: NewsArticle
    private let newsDetailsInteractor: NewsDetailsInteractorProtocol

    var isBookmarked: Bool

    private let router: NewsDetailsRouterProtocol

    // MARK: - Initialization
    init(
        article: NewsArticle,
        newsDetailsInteractor: NewsDetailsInteractorProtocol,
        router: NewsDetailsRouterProtocol
    ) {
        self.article = article
        self.newsDetailsInteractor = newsDetailsInteractor
        self.router = router
        self.isBookmarked = newsDetailsInteractor.isArticleBookmarked(article)
    }

    // MARK: - Public Methods
    func toggleBookmark() {
        // Provide haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()

        if isBookmarked {
            newsDetailsInteractor.removeBookmark(article)
            isBookmarked = false
        } else {
            newsDetailsInteractor.addBookmark(article)
            isBookmarked = true
        }
    }
}
