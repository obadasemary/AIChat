//
//  NewsFeedView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import SwiftUI

struct NewsFeedView: View {

    @State var viewModel: NewsFeedViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedCategory: NewsCategory = .topHeadlines

    var body: some View {
        let _ = Self._printChanges()
        NavigationStack {
            VStack(spacing: 0) {
                categoryPicker
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .systemBackground))

                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        switch viewModel.state {
                        case .idle, .loading:
                            ProgressView()
                                .padding(.vertical, 24)
                        case .error:
                            ContentUnavailableView(
                                "Error",
                                systemImage: "exclamationmark.triangle",
                                description: Text(viewModel.errorMessage ?? "An error occurred")
                            )
                            .padding(.vertical, 24)

                            Button("Retry") {
                                viewModel.refreshData()
                            }
                            .buttonStyle(.borderedProminent)
                        case .loaded, .loadingMore:
                            if viewModel.articles.isEmpty {
                                ContentUnavailableView(
                                    "No News Available",
                                    systemImage: "newspaper",
                                    description: Text("Pull to refresh")
                                )
                                .padding(.vertical, 100)
                            } else {
                                ForEach(viewModel.articles) { article in
                                    NewsArticleRow(article: article)
                                        .onAppear {
                                            if article.id == viewModel.articles.last?.id {
                                                viewModel.loadMoreData()
                                            }
                                        }
                                    Divider()
                                }

                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .padding(.vertical, 16)
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    viewModel.refreshData()
                }
            }
            .navigationTitle("News Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    dataSourceIndicator
                }
            }
            .task {
                viewModel.loadInitialData()
            }
            .onChange(of: viewModel.isConnected) { _, _ in
                viewModel.handleConnectivityChange()
            }
        }
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

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(NewsCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                        switch category {
                        case .topHeadlines:
                            viewModel.loadTopHeadlines(country: "eg")
                        case .tech:
                            viewModel.loadNews(category: "technology")
                        case .business:
                            viewModel.loadNews(category: "business")
                        case .sports:
                            viewModel.loadNews(category: "sports")
                        case .health:
                            viewModel.loadNews(category: "health")
                        case .science:
                            viewModel.loadNews(category: "science")
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - News Category
enum NewsCategory: String, CaseIterable, Identifiable {
    case topHeadlines = "Top Headlines"
    case tech = "Tech"
    case business = "Business"
    case sports = "Sports"
    case health = "Health"
    case science = "Science"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .topHeadlines: return "newspaper"
        case .tech: return "laptopcomputer"
        case .business: return "briefcase"
        case .sports: return "sportscourt"
        case .health: return "heart"
        case .science: return "flask"
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: NewsCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct NewsArticleRow: View {

    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Article Image - Full Width
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(height: 200)
            } else {
                placeholderImage
            }

            // Article Content
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .overlay(
                Image(systemName: "newspaper")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            )
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
