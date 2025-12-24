//
//  BookmarksView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.12.2025.
//

import SwiftUI

struct BookmarksView: View {

    @State var presenter: BookmarksPresenter

    var body: some View {
        Group {
            if presenter.bookmarkedArticles.isEmpty {
                emptyStateView
            } else {
                bookmarksList
            }
        }
        .navigationTitle("Bookmarks")
        .screenAppearAnalytics(name: "BookmarksView")
        .task {
            presenter.loadBookmarks()
        }
        .refreshable {
            presenter.loadBookmarks()
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Bookmarks Yet",
            systemImage: "bookmark.slash",
            description: Text("Articles you bookmark will appear here for easy access later.")
        )
        .accessibilityLabel("No bookmarks")
        .accessibilityHint("Bookmark articles from the news feed to see them here")
    }

    private var bookmarksList: some View {
        List {
            ForEach(presenter.bookmarkedArticles) { article in
                ArticleRowView(article: article)
                    .anyButton(.highlight) {
                        presenter.onArticleSelected(article: article)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            presenter.removeBookmark(article: article)
                        } label: {
                            Label("Remove", systemImage: "bookmark.slash")
                        }
                        .accessibilityLabel("Remove bookmark")
                        .accessibilityHint("Removes this article from your bookmarks")
                    }
                    .removeListRowFormatting()
            }
        }
    }
}

// MARK: - ArticleRowView
private struct ArticleRowView: View {

    let article: NewsArticle

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Article Image
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(width: 80, height: 80)
            } else {
                placeholderImage
            }

            // Article Content
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                    .accessibilityAddTraits(.isHeader)

                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Text(article.source.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("·")
                        .foregroundStyle(.secondary)

                    Text(article.publishedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.title), \(article.source.name)")
        .accessibilityHint("Double tap to read full article")
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "newspaper")
                    .font(.title2)
                    .foregroundStyle(.gray)
            )
    }
}

#Preview("With Bookmarks") {
    let container = DevPreview.shared.container
    let bookmarkManager = BookmarkManager(isStoredInMemoryOnly: true)
    NewsArticle.mocks.forEach { article in
        bookmarkManager.addBookmark(article)
    }
    container.register(BookmarkManager.self, bookmarkManager)

    let bookmarksBuilder = BookmarksBuilder(container: container)

    return RouterView { router in
        bookmarksBuilder.buildBookmarksView(router: router)
    }
    .previewEnvironment()
}

#Preview("Empty State") {
    let container = DevPreview.shared.container
    let bookmarkManager = BookmarkManager(isStoredInMemoryOnly: true)
    container.register(BookmarkManager.self, bookmarkManager)

    let bookmarksBuilder = BookmarksBuilder(container: container)

    return RouterView { router in
        bookmarksBuilder.buildBookmarksView(router: router)
    }
    .previewEnvironment()
}
