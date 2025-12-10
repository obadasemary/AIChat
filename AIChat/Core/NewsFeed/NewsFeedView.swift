//
//  NewsFeedView.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import SwiftUI

struct NewsFeedView: View {

    @State var viewModel: NewsFeedViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading news...")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.articles.isEmpty {
                    ContentUnavailableView(
                        "No News Available",
                        systemImage: "newspaper",
                        description: Text("Pull to refresh")
                    )
                } else {
                    newsList
                }
            }
            .navigationTitle("News Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    dataSourceIndicator
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadTopHeadlines()
            }
        }
    }

    private var newsList: some View {
        List(viewModel.articles) { article in
            NewsArticleRow(article: article)
        }
        .listStyle(.plain)
    }

    private var dataSourceIndicator: some View {
        Group {
            if viewModel.isDataFromRemote {
                Label("Live", systemImage: "wifi")
                    .foregroundStyle(.green)
            } else if viewModel.isDataFromLocal {
                Label("Cached", systemImage: "arrow.clockwise.icloud")
                    .foregroundStyle(.orange)
            }
        }
        .font(.caption)
    }
}

struct NewsArticleRow: View {

    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .lineLimit(2)

            if let description = article.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack {
                Text(article.source.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(article.publishedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let container = DevPreview.shared.container
    
    let newsFeedBuilder = NewsFeedBuilder(container: container)
    
    return RouterView { router in
        newsFeedBuilder.buildNewsFeedView()
    }
    .previewEnvironment()
}
