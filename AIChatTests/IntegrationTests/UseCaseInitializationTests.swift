//
//  UseCaseInitializationTests.swift
//  AIChatTests
//
//  Created by Antigravity on 21.12.2025.
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

    @Test func test_AboutUseCase_initialization() {
        let _ = AboutUseCase(container: container)
    }

    @Test func test_AppViewUseCase_initialization() {
        let _ = AppViewUseCase(container: container)
    }

    @Test func test_BookmarksUseCase_initialization() {
        let _ = BookmarksUseCase(container: container)
    }

    @Test func test_CategoryListUseCase_initialization() {
        let _ = CategoryListUseCase(container: container)
    }

    @Test func test_ChatUseCase_initialization() {
        let _ = ChatUseCase(container: container)
    }

    @Test func test_ChatRowCellUseCase_initialization() {
        let _ = ChatRowCellUseCase(container: container)
    }

    @Test func test_ChatsUseCase_initialization() {
        let _ = ChatsUseCase(container: container)
    }

    @Test func test_CreateAccountUseCase_initialization() {
        let _ = CreateAccountUseCase(container: container)
    }

    @Test func test_CreateAvatarUseCase_initialization() {
        let _ = CreateAvatarUseCase(container: container)
    }

    @Test func test_DevSettingsUseCase_initialization() {
        let _ = DevSettingsUseCase(container: container)
    }

    @Test func test_ExploreUseCase_initialization() {
        let _ = ExploreUseCase(container: container)
    }

    @Test func test_NewsDetailsUseCase_initialization() {
        let _ = NewsDetailsUseCase(container: container)
    }

    @Test func test_NewsFeedUseCase_initialization() {
        let _ = NewsFeedUseCase(container: container)
    }

    @Test func test_OnboardingColorUseCase_initialization() {
        let _ = OnboardingColorUseCase(container: container)
    }

    @Test func test_OnboardingCommunityUseCase_initialization() {
        let _ = OnboardingCommunityUseCase(container: container)
    }

    @Test func test_OnboardingCompletedUseCase_initialization() {
        let _ = OnboardingCompletedUseCase(container: container)
    }

    @Test func test_OnboardingIntroUseCase_initialization() {
        let _ = OnboardingIntroUseCase(container: container)
    }

    @Test func test_PaywallUseCase_initialization() {
        let _ = PaywallUseCase(container: container)
    }

    @Test func test_ProfileUseCase_initialization() {
        let _ = ProfileUseCase(container: container)
    }

    @Test func test_SettingsUseCase_initialization() {
        let _ = SettingsUseCase(container: container)
    }

    @Test func test_WelcomeUseCase_initialization() {
        let _ = WelcomeUseCase(container: container)
    }
}
