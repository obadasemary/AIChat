//
//  NewsFeedViewModel.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation

@MainActor
@Observable
final class NewsFeedViewModel {

    private let newsFeedUseCase: NewsFeedUseCase

    var articles: [NewsArticle] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var dataSource: NewsFeedResult.DataSource?

    var isDataFromRemote: Bool {
        dataSource == .remote
    }

    var isDataFromLocal: Bool {
        dataSource == .local
    }

    init(newsFeedUseCase: NewsFeedUseCase) {
        self.newsFeedUseCase = newsFeedUseCase
    }

    func loadNews(category: String? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await newsFeedUseCase.loadNews(category: category)
            articles = result.articles
            dataSource = result.source
        } catch {
            errorMessage = error.localizedDescription
            articles = []
            dataSource = nil
        }

        isLoading = false
    }

    func loadTopHeadlines(country: String? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await newsFeedUseCase.loadTopHeadlines(country: country)
            articles = result.articles
            dataSource = result.source
        } catch {
            errorMessage = error.localizedDescription
            articles = []
            dataSource = nil
        }

        isLoading = false
    }

    func refresh() async {
        await loadTopHeadlines()
    }
}
