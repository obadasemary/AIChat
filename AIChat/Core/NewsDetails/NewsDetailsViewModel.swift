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
    private let bookmarkManager: BookmarkManager

    var isBookmarked: Bool {
        bookmarkManager.isBookmarked(articleId: article.id)
    }

    private let router: NewsDetailsRouterProtocol

    // MARK: - Initialization
    init(
        article: NewsArticle,
        newsDetailsUseCase: NewsDetailsUseCaseProtocol,
        router: NewsDetailsRouterProtocol
    ) {
        self.article = article
        self.newsDetailsUseCase = newsDetailsUseCase
        self.bookmarkManager = newsDetailsUseCase.bookmarkManager
        self.router = router
    }

    // MARK: - Public Methods
    func toggleBookmark() {
        // Provide haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()

        if isBookmarked {
            newsDetailsUseCase.removeBookmark(article)
        } else {
            newsDetailsUseCase.addBookmark(article)
        }
    }
}
