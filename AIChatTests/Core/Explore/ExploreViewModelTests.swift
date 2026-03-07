//
//  ExploreViewModelTests.swift
//  AIChatTests
//
//  Created by Claude on 22.02.2026.
//

import Testing
import Foundation
@testable import AIChat

@MainActor
struct ExploreViewModelTests {

    // MARK: - Load Featured Avatars

    @Test("Load Featured Avatars - populates featuredAvatars and stops loading")
    func test_loadFeaturedAvatars_loadsWhenEmpty() async {
        let mockUseCase = MockExploreUseCase()
        mockUseCase.featuredAvatarsToReturn = AvatarModel.mocks
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        await viewModel.loadFeaturedAvatars()

        #expect(viewModel.featuredAvatars.count == AvatarModel.mocks.count)
        #expect(viewModel.isLoadingFeatured == false)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName == "ExploreView_LoadFeaturedAvatars_Start" })
        #expect(mockUseCase.trackedEvents.contains { $0.eventName == "ExploreView_LoadFeaturedAvatars_Success" })
    }

    @Test("Load Featured Avatars - skips fetch when already loaded and force is false")
    func test_loadFeaturedAvatars_skipsWhenAlreadyLoaded() async {
        let mockUseCase = MockExploreUseCase()
        mockUseCase.featuredAvatarsToReturn = AvatarModel.mocks
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        // Load once
        await viewModel.loadFeaturedAvatars()
        let firstCallCount = mockUseCase.getFeaturedAvatarsCallCount

        // Load again without force
        await viewModel.loadFeaturedAvatars(force: false)

        #expect(mockUseCase.getFeaturedAvatarsCallCount == firstCallCount)
    }

    @Test("Load Featured Avatars - force refreshes even when already loaded")
    func test_loadFeaturedAvatars_forceRefreshesEvenWhenLoaded() async {
        let mockUseCase = MockExploreUseCase()
        mockUseCase.featuredAvatarsToReturn = AvatarModel.mocks
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        await viewModel.loadFeaturedAvatars()
        let firstCallCount = mockUseCase.getFeaturedAvatarsCallCount

        await viewModel.loadFeaturedAvatars(force: true)

        #expect(mockUseCase.getFeaturedAvatarsCallCount > firstCallCount)
    }

    @Test("Load Featured Avatars Failure - tracks error event and stops loading")
    func test_loadFeaturedAvatars_failure_tracksErrorEvent() async {
        let mockUseCase = MockExploreUseCase()
        mockUseCase.shouldFailGetFeaturedAvatars = true
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        await viewModel.loadFeaturedAvatars()

        #expect(viewModel.featuredAvatars.isEmpty)
        #expect(viewModel.isLoadingFeatured == false)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName == "ExploreView_LoadFeaturedAvatars_Fail" })
    }

    // MARK: - Load Popular Avatars

    @Test("Load Popular Avatars - populates popularAvatars and stops loading")
    func test_loadPopularAvatars_loadsWhenEmpty() async {
        let mockUseCase = MockExploreUseCase()
        mockUseCase.popularAvatarsToReturn = AvatarModel.mocks
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        await viewModel.loadPopularAvatars()

        #expect(viewModel.popularAvatars.count == AvatarModel.mocks.count)
        #expect(viewModel.isLoadingPopular == false)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName == "ExploreView_LoadPopularAvatars_Success" })
    }

    @Test("Load Popular Avatars Failure - tracks error event and stops loading")
    func test_loadPopularAvatars_failure_tracksErrorEvent() async {
        let mockUseCase = MockExploreUseCase()
        mockUseCase.shouldFailGetPopularAvatars = true
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        await viewModel.loadPopularAvatars()

        #expect(viewModel.popularAvatars.isEmpty)
        #expect(viewModel.isLoadingPopular == false)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName == "ExploreView_LoadPopularAvatars_Fail" })
    }

    // MARK: - Deep Link

    @Test("Handle Deep Link - category query shows category list view")
    func test_handleDeepLink_category_showsCategoryList() {
        let mockUseCase = MockExploreUseCase()
        let mockRouter = MockExploreRouter()
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: mockRouter)

        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "aichat://explore?category=alien")!
        viewModel.handleDeepLink(url)

        #expect(mockRouter.showCategoryListViewCalled)
        #expect(mockRouter.categoryListDelegate?.category == .alien)
    }

    @Test("Handle Deep Link - avatarId query shows chat view")
    func test_handleDeepLink_avatarId_showsChatView() {
        let mockUseCase = MockExploreUseCase()
        let mockRouter = MockExploreRouter()
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: mockRouter)
        let targetAvatarId = "avatar-123"

        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "aichat://explore?avatarId=\(targetAvatarId)")!
        viewModel.handleDeepLink(url)

        #expect(mockRouter.showChatViewCalled)
        #expect(mockRouter.chatDelegate?.avatarId == targetAvatarId)
    }

    @Test(
        "Handle Deep Link - screen parameter switches tab",
        arguments: [
            ("chats", AppTab.chats, "ExploreView_DeepLink_Chats"),
            ("profile", AppTab.profile, "ExploreView_DeepLink_Profile")
        ]
    )
    func test_handleDeepLink_screen_switchesTab(screen: String, tab: AppTab, eventName: String) {
        let mockUseCase = MockExploreUseCase()
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "aichat://explore?screen=\(screen)")!
        viewModel.handleDeepLink(url)

        #expect(mockUseCase.switchedToTab == tab)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName == eventName })
    }

    @Test(
        "Handle Deep Link - screen parameter shows view",
        arguments: [
            ("settings", "ExploreView_DeepLink_Settings", \MockExploreRouter.showSettingsViewCalled),
            ("createAvatar", "ExploreView_DeepLink_CreateAvatar", \MockExploreRouter.showCreateAvatarViewCalled)
        ]
    )
    func test_handleDeepLink_screen_showsView(
        screen: String,
        eventName: String,
        routerAssertion: KeyPath<MockExploreRouter, Bool>
    ) {
        let mockUseCase = MockExploreUseCase()
        let mockRouter = MockExploreRouter()
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: mockRouter)

        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "aichat://explore?screen=\(screen)")!
        viewModel.handleDeepLink(url)

        #expect(mockRouter[keyPath: routerAssertion])
        #expect(mockUseCase.trackedEvents.contains { $0.eventName == eventName })
    }

    @Test("Handle Deep Link - no query items tracks no-query-items event")
    func test_handleDeepLink_noQueryItems_tracksEvent() {
        let mockUseCase = MockExploreUseCase()
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "aichat://explore")!
        viewModel.handleDeepLink(url)

        #expect(mockUseCase.trackedEvents.contains { $0.eventName == "ExploreView_DeepLink_NoQueryItems" })
    }

    @Test("Handle Deep Link - unknown params tracks unknown event")
    func test_handleDeepLink_unknownParams_tracksUnknownEvent() {
        let mockUseCase = MockExploreUseCase()
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "aichat://explore?unknownParam=value")!
        viewModel.handleDeepLink(url)

        #expect(mockUseCase.trackedEvents.contains { $0.eventName == "ExploreView_DeepLink_Unknown" })
    }

    // MARK: - Avatar / Category Selection

    @Test("Avatar Selected - shows chat view with correct avatarId")
    func test_onAvatarSelected_showsChatView() {
        let mockRouter = MockExploreRouter()
        let viewModel = ExploreViewModel(exploreUseCase: MockExploreUseCase(), router: mockRouter)
        let avatar = AvatarModel.mock

        viewModel.onAvatarSelected(avatar: avatar)

        #expect(mockRouter.showChatViewCalled)
        #expect(mockRouter.chatDelegate?.avatarId == avatar.avatarId)
    }

    @Test("Category Selected - shows category list with correct category")
    func test_onCategorySelected_showsCategoryList() {
        let mockRouter = MockExploreRouter()
        let viewModel = ExploreViewModel(exploreUseCase: MockExploreUseCase(), router: mockRouter)

        viewModel.onCategorySelected(category: .dog, imageName: "dog_image")

        #expect(mockRouter.showCategoryListViewCalled)
        #expect(mockRouter.categoryListDelegate?.category == .dog)
    }

    // MARK: - A/B Test

    @Test("categoryRowTest - delegates to use case")
    func test_categoryRowTest_delegatesToUseCase() {
        let mockUseCase = MockExploreUseCase()
        mockUseCase.categoryRowTestToReturn = .top
        let viewModel = ExploreViewModel(exploreUseCase: mockUseCase, router: MockExploreRouter())

        #expect(viewModel.categoryRowTest == .top)
    }
}

// MARK: - MockExploreUseCase

@MainActor
final class MockExploreUseCase: ExploreUseCaseProtocol {

    var categoryRowTest: CategoryRowTestOption { categoryRowTestToReturn }
    var categoryRowTestToReturn: CategoryRowTestOption = .original
    var createAccountTest: Bool = false
    var auth: UserAuthInfo? = UserAuthInfo.mock()
    var trackedEvents: [any LoggableEvent] = []
    var switchedToTab: AppTab?

    var shouldFailGetFeaturedAvatars: Bool = false
    var shouldFailGetPopularAvatars: Bool = false
    var featuredAvatarsToReturn: [AvatarModel] = []
    var popularAvatarsToReturn: [AvatarModel] = []
    var getFeaturedAvatarsCallCount: Int = 0
    var getPopularAvatarsCallCount: Int = 0

    func getFeaturedAvatars() async throws -> [AvatarModel] {
        getFeaturedAvatarsCallCount += 1
        if shouldFailGetFeaturedAvatars { throw MockExploreError.fetchFailed }
        return featuredAvatarsToReturn
    }

    func getPopularAvatars() async throws -> [AvatarModel] {
        getPopularAvatarsCallCount += 1
        if shouldFailGetPopularAvatars { throw MockExploreError.fetchFailed }
        return popularAvatarsToReturn
    }

    func schedulePushNotificationForTheNextWeek() {}

    func canRequestAuthorization() async -> Bool { false }

    func requestAuthorization() async throws -> Bool { false }

    func updateAppState(showTabBarView: Bool) {}

    func switchToTab(_ tab: AppTab) {
        switchedToTab = tab
    }

    func signOut() throws {}

    func trackEvent(event: any LoggableEvent) {
        trackedEvents.append(event)
    }

    enum MockExploreError: Error {
        case fetchFailed
    }
}

// MARK: - MockExploreRouter

@MainActor
final class MockExploreRouter: ExploreRouterProtocol {

    private(set) var showCategoryListViewCalled: Bool = false
    private(set) var categoryListDelegate: CategoryListDelegate?

    private(set) var showChatViewCalled: Bool = false
    private(set) var chatDelegate: ChatDelegate?

    private(set) var showDevSettingsViewCalled: Bool = false
    private(set) var showCreateAccountViewCalled: Bool = false
    private(set) var showSettingsViewCalled: Bool = false
    private(set) var showProfileViewCalled: Bool = false
    private(set) var showCreateAvatarViewCalled: Bool = false
    private(set) var dismissScreenCalled: Bool = false
    private(set) var showPushNotificationModalCalled: Bool = false
    private(set) var dismissModalCalled: Bool = false
    private(set) var dismissAlertCalled: Bool = false

    func showCategoryListView(delegate: CategoryListDelegate) {
        showCategoryListViewCalled = true
        categoryListDelegate = delegate
    }

    func showChatView(delegate: ChatDelegate) {
        showChatViewCalled = true
        chatDelegate = delegate
    }

    func showDevSettingsView() {
        showDevSettingsViewCalled = true
    }

    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?) {
        showCreateAccountViewCalled = true
    }

    func showSettingsView(onSignedIn: @escaping () -> Void, onDisappear: @escaping () -> Void) {
        showSettingsViewCalled = true
    }

    func showProfileView() {
        showProfileViewCalled = true
    }

    func showCreateAvatarView(onDisappear: @escaping () -> Void) {
        showCreateAvatarViewCalled = true
    }

    func dismissScreen() {
        dismissScreenCalled = true
    }

    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) {
        showPushNotificationModalCalled = true
    }

    func dismissModal() {
        dismissModalCalled = true
    }

    func dismissAlert() {
        dismissAlertCalled = true
    }
}
