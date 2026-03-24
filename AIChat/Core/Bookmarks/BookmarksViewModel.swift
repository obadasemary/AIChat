//
//  BookmarksViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import Foundation

@Observable
@MainActor
final class BookmarksViewModel {

    private let bookmarksUseCase: BookmarksUseCaseProtocol
    private let router: BookmarksRouterProtocol

    private(set) var bookmarkedArticles: [NewsArticle] = []

    init(
        bookmarksUseCase: BookmarksUseCaseProtocol,
        router: BookmarksRouterProtocol
    ) {
        self.bookmarksUseCase = bookmarksUseCase
        self.router = router
    }

    func loadBookmarks() {
        bookmarksUseCase.trackEvent(event: Event.loadBookmarksStart)
        bookmarkedArticles = bookmarksUseCase.getBookmarkedArticles()
        bookmarksUseCase.trackEvent(
            event: Event.loadBookmarksSuccess(count: bookmarkedArticles.count)
        )
    }

    func onArticleSelected(article: NewsArticle) {
        bookmarksUseCase.trackEvent(event: Event.articlePressed(article: article))
        router.showNewsDetailsView(article: article)
    }

    func removeBookmark(article: NewsArticle) {
        bookmarksUseCase.trackEvent(event: Event.removeBookmarkPressed(article: article))
        bookmarksUseCase.removeBookmark(articleId: article.id)
        loadBookmarks()
    }
}

// MARK: - Event
private extension BookmarksViewModel {

    enum Event: LoggableEvent {
        case loadBookmarksStart
        case loadBookmarksSuccess(count: Int)
        case articlePressed(article: NewsArticle)
        case removeBookmarkPressed(article: NewsArticle)

        var eventName: String {
            switch self {
            case .loadBookmarksStart: "BookmarksView_LoadBookmarks_Start"
            case .loadBookmarksSuccess: "BookmarksView_LoadBookmarks_Success"
            case .articlePressed: "BookmarksView_Article_Pressed"
            case .removeBookmarkPressed: "BookmarksView_RemoveBookmark_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadBookmarksSuccess(count: let count):
                ["bookmarks_count": count]
            case .articlePressed(article: let article),
                 .removeBookmarkPressed(article: let article):
                [
                    "article_id": article.id,
                    "article_title": article.title
                ]
            default:
                nil
            }
        }

        var type: LogType {
            .analytic
        }
    }
}
