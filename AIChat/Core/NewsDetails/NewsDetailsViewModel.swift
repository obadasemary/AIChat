//
//  NewsDetailsViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import Foundation
import UIKit

@MainActor
@Observable
final class NewsDetailsViewModel {

    // MARK: - Properties
    let article: NewsArticle
    private let newsDetailsUseCase: NewsDetailsUseCaseProtocol

    var isBookmarked: Bool

    private let router: NewsDetailsRouterProtocol

    // MARK: - Initialization
    init(
        article: NewsArticle,
        newsDetailsUseCase: NewsDetailsUseCaseProtocol,
        router: NewsDetailsRouterProtocol
    ) {
        self.article = article
        self.newsDetailsUseCase = newsDetailsUseCase
        self.router = router
        self.isBookmarked = newsDetailsUseCase.isArticleBookmarked(article)
    }

    // MARK: - Public Methods
    func toggleBookmark() {
        // Provide haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()

        if isBookmarked {
            newsDetailsUseCase.removeBookmark(article)
            isBookmarked = false
        } else {
            newsDetailsUseCase.addBookmark(article)
            isBookmarked = true
        }
    }
}
