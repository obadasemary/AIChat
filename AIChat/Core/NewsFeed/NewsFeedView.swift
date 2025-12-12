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
    @State private var selectedCountry: NewsCountry = .egypt
    @State private var selectedLanguage: NewsLanguage = .arabic
    @State private var showSettings: Bool = false
    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    dataSourceIndicator
                }
            }
            .sheet(isPresented: $showSettings) {
                settingsSheet
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
                ForEach(availableCategories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                        loadCategory(category)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var availableCategories: [NewsCategory] {
        // Only show Top Headlines if the selected country supports it
        if selectedCountry.supportsTopHeadlines {
            return NewsCategory.allCases
        } else {
            return NewsCategory.allCases.filter { $0 != .topHeadlines }
        }
    }

    private func loadCategory(_ category: NewsCategory) {
        if category == .topHeadlines {
            viewModel.loadTopHeadlines(
                country: selectedCountry.code,
                language: selectedLanguage.code
            )
        } else if let query = category.query {
            viewModel.loadNews(
                category: query.rawValue,
                language: selectedLanguage.code
            )
        }
    }
    
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section("Language") {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(NewsLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Country (for Top Headlines)") {
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(NewsCountry.allCases) { country in
                            Text("\(country.flag) \(country.displayName)").tag(country)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button("Apply Settings") {
                        showSettings = false

                        // If Top Headlines is selected but not supported by new country, switch to Tech
                        if selectedCategory == .topHeadlines && !selectedCountry.supportsTopHeadlines {
                            selectedCategory = .tech
                        }

                        // Reload current category with new settings
                        loadCategory(selectedCategory)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("News Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showSettings = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - News Language
enum NewsLanguage: String, CaseIterable, Identifiable {
    case arabic = "ar"
    case english = "en"
    case french = "fr"
    case german = "de"
    case spanish = "es"
    case italian = "it"
    case turkish = "tr"

    var id: String { rawValue }

    var code: String { rawValue }

    var displayName: String {
        switch self {
        case .arabic: return "العربية (Arabic)"
        case .english: return "English"
        case .french: return "Français (French)"
        case .german: return "Deutsch (German)"
        case .spanish: return "Español (Spanish)"
        case .italian: return "Italiano (Italian)"
        case .turkish: return "Türkçe (Turkish)"
        }
    }
}

// MARK: - News Country
enum NewsCountry: String, CaseIterable, Identifiable {
    case egypt = "eg"
    case unitedStates = "us"
    case unitedKingdom = "gb"
    case germany = "de"
    case france = "fr"
    case italy = "it"
    case spain = "es"
    case saudiArabia = "sa"
    case uae = "ae"
    case turkey = "tr"

    var id: String { rawValue }

    var code: String { rawValue }

    var displayName: String {
        switch self {
        case .egypt: return "Egypt"
        case .unitedStates: return "United States"
        case .unitedKingdom: return "United Kingdom"
        case .germany: return "Germany"
        case .france: return "France"
        case .italy: return "Italy"
        case .spain: return "Spain"
        case .saudiArabia: return "Saudi Arabia"
        case .uae: return "United Arab Emirates"
        case .turkey: return "Turkey"
        }
    }

    var flag: String {
        switch self {
        case .egypt: return "🇪🇬"
        case .unitedStates: return "🇺🇸"
        case .unitedKingdom: return "🇬🇧"
        case .germany: return "🇩🇪"
        case .france: return "🇫🇷"
        case .italy: return "🇮🇹"
        case .spain: return "🇪🇸"
        case .saudiArabia: return "🇸🇦"
        case .uae: return "🇦🇪"
        case .turkey: return "🇹🇷"
        }
    }

    var supportsTopHeadlines: Bool {
        // News API supports top headlines for these countries
        switch self {
        case .egypt, .unitedStates, .unitedKingdom, .germany, .france, .italy, .spain, .saudiArabia, .uae, .turkey:
            return true
        }
    }
}

// MARK: - News Category Query
enum NewsCategoryQuery: String {
    case technology
    case business
    case sports
    case health
    case science
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

    var query: NewsCategoryQuery? {
        switch self {
        case .topHeadlines: return nil
        case .tech: return .technology
        case .business: return .business
        case .sports: return .sports
        case .health: return .health
        case .science: return .science
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
