//
//  AdminViewModelTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.02.2026.
//

import SwiftUI
import Testing
@testable import AIChat

@MainActor
struct AdminViewModelTests {

    @Test("Initial State Defaults")
    func testInitialStateDefaults() {
        let viewModel = AdminViewModel(
            adminUseCase: MockAdminUseCase(),
            router: MockAdminRouter()
        )

        #expect(viewModel.isLoading == false)
        #expect(viewModel.isDeleting == false)
        #expect(viewModel.chatCount == 0)
        #expect(viewModel.avatarCount == 0)
        #expect(viewModel.bookmarkCount == 0)
        #expect(viewModel.pushStatus == "Checking...")
    }

    @Test("User Info Computed Properties")
    func testUserInfoComputedProperties() {
        let creationDate = Date(timeIntervalSince1970: 0)
        let lastSignInDate = Date(timeIntervalSince1970: 1_000)
        let auth = UserAuthInfo(
            uid: "user_1",
            email: "user@example.com",
            isAnonymous: true,
            creationDate: creationDate,
            lastSignInDate: lastSignInDate
        )
        let user = UserModel(userId: "user_1", didCompleteOnboarding: true)
        let useCase = MockAdminUseCase(auth: auth, currentUser: user)

        let viewModel = AdminViewModel(
            adminUseCase: useCase,
            router: MockAdminRouter()
        )

        #expect(viewModel.userId == "user_1")
        #expect(viewModel.userEmail == "user@example.com")
        #expect(viewModel.isAnonymous == true)
        #expect(viewModel.didCompleteOnboarding == true)
        #expect(viewModel.accountCreationDate != "N/A")
        #expect(viewModel.lastSignInDate != "N/A")
    }

    @Test("Premium Status and Entitlements")
    func testPremiumStatusAndEntitlements() {
        let expirationDate = Date(timeIntervalSince1970: 10_000)
        let entitlement = PurchasedEntitlement(
            id: "entitlement_1",
            productId: "premium.monthly",
            expirationDate: expirationDate,
            isActive: true,
            originalPurchaseDate: nil,
            latestPurchaseDate: nil,
            ownershipType: .purchased,
            isSandbox: false,
            isVerified: true
        )
        let useCase = MockAdminUseCase(entitlements: [entitlement])

        let viewModel = AdminViewModel(
            adminUseCase: useCase,
            router: MockAdminRouter()
        )

        #expect(viewModel.isPremium == true)
        #expect(viewModel.premiumStatus == "Premium")
        #expect(viewModel.premiumProductId == "premium.monthly")
        #expect(viewModel.premiumExpirationDate != "N/A")
    }

    @Test("Network Status and Connection Type")
    func testNetworkStatusAndConnectionType() {
        let useCase = MockAdminUseCase(
            isNetworkConnected: true,
            networkConnectionType: .wifi
        )
        let viewModel = AdminViewModel(
            adminUseCase: useCase,
            router: MockAdminRouter()
        )

        #expect(viewModel.isNetworkConnected == true)
        #expect(viewModel.networkStatus == "Connected")
        #expect(viewModel.connectionType == "WiFi")
    }

    @Test("Load Data Success Updates Counts and Push Status")
    func testLoadDataSuccessUpdatesCountsAndPushStatus() async {
        let useCase = MockAdminUseCase(
            canRequestPushAuthorizationResult: true,
            chatCount: 4,
            avatarCount: 2,
            bookmarkCount: 7
        )
        let viewModel = AdminViewModel(
            adminUseCase: useCase,
            router: MockAdminRouter()
        )

        viewModel.loadData()
        await waitForPredicate {
            viewModel.pushStatus != "Checking..." ||
            viewModel.chatCount != 0 ||
            viewModel.avatarCount != 0 ||
            viewModel.bookmarkCount != 0
        }

        #expect(viewModel.chatCount == 4)
        #expect(viewModel.avatarCount == 2)
        #expect(viewModel.bookmarkCount == 7)
        #expect(viewModel.pushStatus == "Not Requested")

        let screenEvents = useCase.trackedEvents.filter {
            $0.eventName == "AdminView_Screen_Appeared"
        }
        #expect(screenEvents.count == 1)
    }

    @Test("Load Data Failure Tracks Error Event")
    func testLoadDataFailureTracksErrorEvent() async {
        let useCase = MockAdminUseCase(
            canRequestPushAuthorizationResult: false,
            chatCountError: TestError.testError
        )
        let viewModel = AdminViewModel(
            adminUseCase: useCase,
            router: MockAdminRouter()
        )

        viewModel.loadData()
        await waitForPredicate {
            viewModel.pushStatus != "Checking..."
        }

        let errorEvents = useCase.trackedEvents.filter {
            $0.eventName == "AdminView_LoadData_Failed"
        }
        #expect(errorEvents.count == 1)
        #expect(viewModel.pushStatus == "Authorized/Denied")
    }

    @Test("Clear All Chats Pressed Shows Alert and Tracks Event")
    func testClearAllChatsPressedShowsAlertAndTracksEvent() {
        let useCase = MockAdminUseCase()
        let router = MockAdminRouter()
        let viewModel = AdminViewModel(
            adminUseCase: useCase,
            router: router
        )

        viewModel.onClearAllChatsPressed()

        #expect(router.lastAlertTitle == "Clear All Chats?")
        #expect(router.lastAlertSubtitle?.contains("permanently delete") == true)

        let pressedEvents = useCase.trackedEvents.filter {
            $0.eventName == "AdminView_ClearAllChats_Pressed"
        }
        #expect(pressedEvents.count == 1)
    }

    @Test("Refresh Data Pressed Tracks Event")
    func testRefreshDataPressedTracksEvent() async {
        let useCase = MockAdminUseCase(
            canRequestPushAuthorizationResult: true,
            chatCount: 1,
            avatarCount: 1,
            bookmarkCount: 1
        )
        let viewModel = AdminViewModel(
            adminUseCase: useCase,
            router: MockAdminRouter()
        )

        viewModel.onRefreshDataPressed()
        await waitForPredicate {
            viewModel.chatCount == 1
        }

        let refreshEvents = useCase.trackedEvents.filter {
            $0.eventName == "AdminView_RefreshData_Pressed"
        }
        #expect(refreshEvents.count == 1)
        #expect(viewModel.chatCount == 1)
    }

    private func waitForPredicate(_ predicate: @MainActor @escaping () -> Bool) async {
        let maxAttempts = 100

        for _ in 0..<maxAttempts {
            if predicate() {
                return
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        Issue.record("Timed out waiting for async condition")
    }
}

// MARK: - Mocks

@MainActor
final class MockAdminUseCase: AdminUseCaseProtocol {

    var auth: UserAuthInfo?
    var currentUser: UserModel?
    var isNetworkConnected: Bool
    var networkConnectionType: NetworkConnectionType
    var entitlements: [PurchasedEntitlement]
    var activeTests: ActiveABTests

    var canRequestPushAuthorizationResult: Bool
    var chatCount: Int
    var avatarCount: Int
    var bookmarkCount: Int
    var chatCountError: Error?
    var avatarCountError: Error?
    var deleteAllChatsError: Error?

    private(set) var trackedEvents: [any LoggableEvent] = []
    private(set) var deleteAllChatsCalled = false

    var hasActiveEntitlement: Bool {
        entitlements.hasActiveEntitlement
    }

    init(
        auth: UserAuthInfo? = nil,
        currentUser: UserModel? = nil,
        isNetworkConnected: Bool = false,
        networkConnectionType: NetworkConnectionType = .unknown,
        entitlements: [PurchasedEntitlement] = [],
        activeTests: ActiveABTests = ActiveABTests(
            createAccountTest: false,
            onboardingCommunityTest: false,
            categoryRowTest: .default,
            paywallOption: .custom
        ),
        canRequestPushAuthorizationResult: Bool = false,
        chatCount: Int = 0,
        avatarCount: Int = 0,
        bookmarkCount: Int = 0,
        chatCountError: Error? = nil,
        avatarCountError: Error? = nil,
        deleteAllChatsError: Error? = nil
    ) {
        self.auth = auth
        self.currentUser = currentUser
        self.isNetworkConnected = isNetworkConnected
        self.networkConnectionType = networkConnectionType
        self.entitlements = entitlements
        self.activeTests = activeTests
        self.canRequestPushAuthorizationResult = canRequestPushAuthorizationResult
        self.chatCount = chatCount
        self.avatarCount = avatarCount
        self.bookmarkCount = bookmarkCount
        self.chatCountError = chatCountError
        self.avatarCountError = avatarCountError
        self.deleteAllChatsError = deleteAllChatsError
    }

    func canRequestPushAuthorization() async -> Bool {
        canRequestPushAuthorizationResult
    }

    func getChatCount() async throws -> Int {
        if let chatCountError {
            throw chatCountError
        }
        return chatCount
    }

    func getAvatarCount() async throws -> Int {
        if let avatarCountError {
            throw avatarCountError
        }
        return avatarCount
    }

    func getBookmarkCount() -> Int {
        bookmarkCount
    }

    func deleteAllChats() async throws {
        deleteAllChatsCalled = true
        if let deleteAllChatsError {
            throw deleteAllChatsError
        }
    }

    func trackEvent(event: any LoggableEvent) {
        trackedEvents.append(event)
    }
}

@MainActor
final class MockAdminRouter: AdminRouterProtocol {

    private(set) var lastAlertType: RouterAlertType?
    private(set) var lastAlertTitle: String?
    private(set) var lastAlertSubtitle: String?
    private(set) var lastAlertButtons: (() -> AnyView)?
    private(set) var showAlertError: Error?
    private(set) var dismissScreenCalled = false

    func showAlert(
        _ option: RouterAlertType,
        title: String,
        subtitle: String?,
        buttons: (@Sendable () -> AnyView)?
    ) {
        lastAlertType = option
        lastAlertTitle = title
        lastAlertSubtitle = subtitle
        lastAlertButtons = buttons
    }

    func showAlert(error: Error) {
        showAlertError = error
    }

    func dismissScreen() {
        dismissScreenCalled = true
    }
}

private enum TestError: Error {
    case testError
}
