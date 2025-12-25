//
//  InteractorInitializationTests.swift
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
        // Override bookmark manager for tests to ensure isolated, in-memory storage
        container.register(
            BookmarkManager.self,
            BookmarkManager(isStoredInMemoryOnly: true, storeName: "TestBookmarks")
        )
    }

    @Test func test_AboutInteractor() {
        let useCase = AboutInteractor(container: container)
        #expect(useCase.appVersion != "Unknown")
    }

    @Test func test_AppViewInteractor() {
        let useCase = AppViewInteractor(container: container)
        #expect(useCase.showTabBar == true)
    }

    @Test func test_BookmarksInteractor() {
        let useCase = BookmarksInteractor(container: container)
        #expect(useCase.getBookmarkedArticles().isEmpty)
    }

    @Test func test_CategoryListInteractor() async throws {
        let useCase = CategoryListInteractor(container: container)
        let avatars = try await useCase.getAvatarsForCategory(category: .default)
        #expect(!avatars.isEmpty)
    }

    @Test func test_ChatInteractor() {
        let useCase = ChatInteractor(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_ChatRowCellInteractor() {
        let useCase = ChatRowCellInteractor(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_ChatsInteractor() throws {
        let useCase = ChatsInteractor(container: container)
        let avatars = try useCase.getRecentAvatars()
        #expect(!avatars.isEmpty)
    }

    @Test func test_CreateAccountInteractor() {
        let _ = CreateAccountInteractor(container: container)
    }

    @Test func test_CreateAvatarInteractor() throws {
        let useCase = CreateAvatarInteractor(container: container)
        #expect(try useCase.getAuthId() != "")
    }

    @Test func test_DevSettingsInteractor() {
        let useCase = DevSettingsInteractor(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_ExploreInteractor() async throws {
        let useCase = ExploreInteractor(container: container)
        #expect(useCase.auth != nil)
        let avatars = try await useCase.getFeaturedAvatars()
        #expect(!avatars.isEmpty)
    }

    @Test func test_NewsDetailsInteractor() {
        let _ = NewsDetailsInteractor(container: container)
    }

    @Test func test_NewsFeedInteractor() async throws {
        let useCase = NewsFeedInteractor(container: container)
        let results = try await useCase.loadNews(page: 1, pageSize: 10)
        #expect(!results.articles.isEmpty)
    }

    @Test func test_OnboardingColorInteractor() {
        let useCase = OnboardingColorInteractor(container: container)
    }

    @Test func test_OnboardingCommunityInteractor() {
        let useCase = OnboardingCommunityInteractor(container: container)
    }

    @Test func test_OnboardingCompletedInteractor() {
        let useCase = OnboardingCompletedInteractor(container: container)
    }

    @Test func test_OnboardingIntroInteractor() {
        let useCase = OnboardingIntroInteractor(container: container)
        #expect(useCase.onboardingCommunityTest == false)
    }

    @Test func test_PaywallInteractor() {
        let _ = PaywallInteractor(container: container)
    }

    @Test func test_ProfileInteractor() {
        let useCase = ProfileInteractor(container: container)
        #expect(useCase.currentUser != nil)
    }

    @Test func test_SettingsInteractor() {
        let useCase = SettingsInteractor(container: container)
        #expect(useCase.auth != nil)
    }

    @Test func test_WelcomeInteractor() {
        let _ = WelcomeInteractor(container: container)
    }
}
