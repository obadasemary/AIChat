//
//  UseCaseInitializationTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 21.12.2025.
//

import Testing
@testable import AIChat

@MainActor
struct UseCaseInitializationTests {

    private let container: DependencyContainer

    init() {
        let deps = Dependencies(configuration: .mock(isSignedIn: true))
        self.container = deps.container
    }

    @Test func test_AboutUseCase() {
        let useCase = AboutUseCase(container: container)
        #expect(useCase.appVersion != "Unknown")
    }

    @Test func test_AppViewUseCase() {
        let useCase = AppViewUseCase(container: container)
        #expect(useCase.showTabBar == true)
    }

    @Test func test_BookmarksUseCase() {
        let useCase = BookmarksUseCase(container: container)
        #expect(useCase.getBookmarkedArticles().isEmpty)
    }

    @Test func test_CategoryListUseCase() async throws {
        let useCase = CategoryListUseCase(container: container)
        let avatars = try await useCase.getAvatarsForCategory(category: .default)
        #expect(!avatars.isEmpty)
    }

    @Test func test_ChatUseCase() {
        let useCase = ChatUseCase(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_ChatRowCellUseCase() {
        let useCase = ChatRowCellUseCase(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_ChatsUseCase() throws {
        let useCase = ChatsUseCase(container: container)
        let avatars = try useCase.getRecentAvatars()
        #expect(!avatars.isEmpty)
    }

    @Test func test_CreateAccountUseCase() {
        let _ = CreateAccountUseCase(container: container)
    }

    @Test func test_CreateAvatarUseCase() throws {
        let useCase = CreateAvatarUseCase(container: container)
        #expect(try useCase.getAuthId() != "")
    }

    @Test func test_DevSettingsUseCase() {
        let useCase = DevSettingsUseCase(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_ExploreUseCase() async throws {
        let useCase = ExploreUseCase(container: container)
        #expect(useCase.auth != nil)
        let avatars = try await useCase.getFeaturedAvatars()
        #expect(!avatars.isEmpty)
    }

    @Test func test_NewsDetailsUseCase() {
        let _ = NewsDetailsUseCase(container: container)
    }

    @Test func test_NewsFeedUseCase() async throws {
        let useCase = NewsFeedUseCase(container: container)
        let results = try await useCase.loadNews(page: 1, pageSize: 10)
        #expect(!results.articles.isEmpty)
    }

    @Test func test_OnboardingColorUseCase() {
        let useCase = OnboardingColorUseCase(container: container)
    }

    @Test func test_OnboardingCommunityUseCase() {
        let useCase = OnboardingCommunityUseCase(container: container)
    }

    @Test func test_OnboardingCompletedUseCase() {
        let useCase = OnboardingCompletedUseCase(container: container)
    }

    @Test func test_OnboardingIntroUseCase() {
        let useCase = OnboardingIntroUseCase(container: container)
        #expect(useCase.onboardingCommunityTest == false)
    }

    @Test func test_PaywallUseCase() {
        let _ = PaywallUseCase(container: container)
    }

    @Test func test_ProfileUseCase() {
        let useCase = ProfileUseCase(container: container)
        #expect(useCase.currentUser != nil)
    }

    @Test func test_SettingsUseCase() {
        let useCase = SettingsUseCase(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_WelcomeUseCase() {
        let _ = WelcomeUseCase(container: container)
    }
}
