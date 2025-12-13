//
//  NewsDetailsViewModel.swift
//  AIChat
//
//  Created by Claude Code on 12.12.2025.
//

import Foundation

@MainActor
@Observable
final class NewsDetailsViewModel {

    // MARK: - Properties
    let article: NewsArticle
    private let newsDetailsUseCase: NewsDetailsUseCaseProtocol

    var isBookmarked: Bool = false

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
        if isBookmarked {
            newsDetailsUseCase.removeBookmark(article)
            isBookmarked = false
        } else {
            newsDetailsUseCase.addBookmark(article)
            isBookmarked = true
        }
    }
}
