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
        let interactor = AboutInteractor(container: container)
        #expect(interactor.appVersion != "Unknown")
    }

    @Test func test_AppViewInteractor() {
        let interactor = AppViewInteractor(container: container)
        #expect(interactor.showTabBar == true)
    }

    @Test func test_BookmarksInteractor() {
        let interactor = BookmarksInteractor(container: container)
        #expect(interactor.getBookmarkedArticles().isEmpty)
    }

    @Test func test_CategoryListInteractor() async throws {
        let interactor = CategoryListInteractor(container: container)
        let avatars = try await interactor.getAvatarsForCategory(category: .default)
        #expect(!avatars.isEmpty)
    }

    @Test func test_ChatInteractor() {
        let interactor = ChatInteractor(container: container)
        #expect(interactor.auth != nil)
    }

    @Test func test_ChatRowCellInteractor() {
        let interactor = ChatRowCellInteractor(container: container)
        #expect(interactor.auth != nil)
    }

    @Test func test_ChatsInteractor() throws {
        let interactor = ChatsInteractor(container: container)
        let avatars = try interactor.getRecentAvatars()
        #expect(!avatars.isEmpty)
    }

    @Test func test_CreateAccountInteractor() {
        let _ = CreateAccountInteractor(container: container)
    }

    @Test func test_CreateAvatarInteractor() throws {
        let interactor = CreateAvatarInteractor(container: container)
        #expect(try interactor.getAuthId() != "")
    }

    @Test func test_DevSettingsInteractor() {
        let interactor = DevSettingsInteractor(container: container)
        #expect(interactor.auth != nil)
    }

    @Test func test_ExploreInteractor() async throws {
        let interactor = ExploreInteractor(container: container)
        #expect(interactor.auth != nil)
        let avatars = try await interactor.getFeaturedAvatars()
        #expect(!avatars.isEmpty)
    }

    @Test func test_NewsDetailsInteractor() {
        let _ = NewsDetailsInteractor(container: container)
    }

    @Test func test_NewsFeedInteractor() async throws {
        let interactor = NewsFeedInteractor(container: container)
        let results = try await interactor.loadNews(page: 1, pageSize: 10)
        #expect(!results.articles.isEmpty)
    }

    @Test func test_OnboardingColorInteractor() {
        let interactor = OnboardingColorInteractor(container: container)
    }

    @Test func test_OnboardingCommunityInteractor() {
        let interactor = OnboardingCommunityInteractor(container: container)
    }

    @Test func test_OnboardingCompletedInteractor() {
        let interactor = OnboardingCompletedInteractor(container: container)
    }

    @Test func test_OnboardingIntroInteractor() {
        let interactor = OnboardingIntroInteractor(container: container)
        #expect(interactor.onboardingCommunityTest == false)
    }

    @Test func test_PaywallInteractor() {
        let _ = PaywallInteractor(container: container)
    }

    @Test func test_ProfileInteractor() {
        let interactor = ProfileInteractor(container: container)
        #expect(interactor.currentUser != nil)
    }

    @Test func test_SettingsInteractor() {
        let interactor = SettingsInteractor(container: container)
        #expect(interactor.auth != nil)
    }

    @Test func test_WelcomeInteractor() {
        let _ = WelcomeInteractor(container: container)
    }
}
