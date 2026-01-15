//
//  NewsDetailsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.12.2025.
//

import SwiftUI

struct NewsDetailsView: View {

    @State var presenter: NewsDetailsPresenter
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Article Image
                if let imageUrl = presenter.article.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .frame(height: 250)
                } else {
                    placeholderImage
                }

                // Article Content
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(presenter.article.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)

                    // Metadata
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "building.2")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(presenter.article.source.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(presenter.article.publishedAt, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(presenter.article.publishedAt, style: .time)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let author = presenter.article.author {
                            HStack {
                                Image(systemName: "person")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(author)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider()
                        .padding(.vertical, 8)

                    // Description
                    if let description = presenter.article.description {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                    }

                    // Content
                    if let content = presenter.article.content {
                        Text(content)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Read More Button
                    if let url = URL(string: presenter.article.url) {
                        Divider()
                            .padding(.vertical, 16)

                        Link(destination: url) {
                            HStack {
                                Text("Read Full Article")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                            }
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if let url = URL(string: presenter.article.url) {
                        ShareLink(item: url) {
                            Label("Share Article", systemImage: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share article")
                        .accessibilityHint("Opens share sheet to share this article")
                    }

                    Button {
                        presenter.toggleBookmark()
                    } label: {
                        Label(
                            presenter.isBookmarked ? "Remove Bookmark" : "Bookmark Article",
                            systemImage: presenter.isBookmarked ? "bookmark.fill" : "bookmark"
                        )
                    }
                    .accessibilityLabel(presenter.isBookmarked ? "Remove bookmark" : "Bookmark article")
                    .accessibilityHint(presenter.isBookmarked ? "Removes this article from your bookmarks" : "Saves this article to your bookmarks")
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Article options")
                .accessibilityHint("Opens menu with sharing and bookmark options")
            }
        }
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .overlay(
                Image(systemName: "newspaper")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
            )
    }
}

#Preview {
    let container = DevPreview.shared.container
    let newsDetailsBuilder = NewsDetailsBuilder(container: container)
    let article = NewsArticle.mock()

    RouterView { router in
        newsDetailsBuilder
            .buildNewsDetailsView(router: router, article: article)
    }
    .previewEnvironment()
}
