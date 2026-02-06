//
//  AdminViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class AdminViewModel {

    private let adminUseCase: AdminUseCaseProtocol
    private let router: AdminRouterProtocol

    // Loading states
    private(set) var isLoading: Bool = false
    private(set) var isDeleting: Bool = false

    // Usage statistics (loaded async)
    private(set) var chatCount: Int = 0
    private(set) var avatarCount: Int = 0
    private(set) var bookmarkCount: Int = 0

    // Push notification status
    private(set) var pushStatus: String = "Checking..."

    init(
        adminUseCase: AdminUseCaseProtocol,
        router: AdminRouterProtocol
    ) {
        self.adminUseCase = adminUseCase
        self.router = router
    }
}

// MARK: - User Info
extension AdminViewModel {

    var userId: String { adminUseCase.auth?.uid ?? "N/A" }
    var userEmail: String { adminUseCase.auth?.email ?? "N/A" }
    var isAnonymous: Bool { adminUseCase.auth?.isAnonymous ?? true }
    var accountCreationDate: String {
        guard let date = adminUseCase.auth?.creationDate else { return "N/A" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    var lastSignInDate: String {
        guard let date = adminUseCase.auth?.lastSignInDate else { return "N/A" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    var didCompleteOnboarding: Bool {
        adminUseCase.currentUser?.didCompleteOnboarding ?? false
    }
    var isPremium: Bool { adminUseCase.hasActiveEntitlement }
    var premiumStatus: String { isPremium ? "Premium" : "Free" }
    var premiumProductId: String {
        adminUseCase.entitlements.first(where: { $0.isActive })?.productId ?? "N/A"
    }
    var premiumExpirationDate: String {
        guard let date = adminUseCase.entitlements.first(where: { $0.isActive })?.expirationDate else {
            return "N/A"
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}

// MARK: - Service Health
extension AdminViewModel {

    var isNetworkConnected: Bool { adminUseCase.isNetworkConnected }
    var networkStatus: String { isNetworkConnected ? "Connected" : "Disconnected" }
    var connectionType: String {
        switch adminUseCase.networkConnectionType {
        case .wifi: return "WiFi"
        case .cellular: return "Cellular"
        case .ethernet: return "Ethernet"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - A/B Tests
extension AdminViewModel {

    var createAccountTest: Bool { adminUseCase.activeTests.createAccountTest }
    var onboardingCommunityTest: Bool { adminUseCase.activeTests.onboardingCommunityTest }
    var categoryRowTest: String { adminUseCase.activeTests.categoryRowTest.rawValue }
    var paywallOption: String { adminUseCase.activeTests.paywallOption.rawValue }
}

// MARK: - Load
extension AdminViewModel {

    func loadData() {
        adminUseCase.trackEvent(event: Event.screenAppeared)

        Task { @MainActor [weak self] in
            guard let self else { return }
            self.isLoading = true

            // Load bookmark count (sync)
            self.bookmarkCount = self.adminUseCase.getBookmarkCount()

            // Load push status
            let canRequest = await self.adminUseCase.canRequestPushAuthorization()
            self.pushStatus = canRequest ? "Not Requested" : "Authorized/Denied"

            // Load async counts
            do {
                self.chatCount = try await self.adminUseCase.getChatCount()
                self.avatarCount = try await self.adminUseCase.getAvatarCount()
            } catch {
                self.adminUseCase.trackEvent(event: Event.loadDataFailed(error: error))
            }

            self.isLoading = false
        }
    }
}

// MARK: - Actions
extension AdminViewModel {

    func onClearAllChatsPressed() {
        adminUseCase.trackEvent(event: Event.clearAllChatsPressed)

        router.showAlert(
            .alert,
            title: "Clear All Chats?",
            subtitle: "This will permanently delete all your chat history. This action cannot be undone.",
            buttons: {
                AnyView(
                    Button("Delete All", role: .destructive) {
                        self.performClearAllChats()
                    }
                )
            }
        )
    }

    func onRefreshDataPressed() {
        adminUseCase.trackEvent(event: Event.refreshDataPressed)
        loadData()
    }

    private func performClearAllChats() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.isDeleting = true

            do {
                try await self.adminUseCase.deleteAllChats()
                self.adminUseCase.trackEvent(event: Event.clearAllChatsSuccess)
                self.chatCount = 0
                self.router.showAlert(
                    .alert,
                    title: "Success",
                    subtitle: "All chats have been deleted.",
                    buttons: nil
                )
            } catch {
                self.adminUseCase.trackEvent(event: Event.clearAllChatsFailed(error: error))
                self.router.showAlert(error: error)
            }

            self.isDeleting = false
        }
    }
}

// MARK: - Event
private extension AdminViewModel {

    enum Event: LoggableEvent {
        case screenAppeared
        case loadDataFailed(error: Error)
        case clearAllChatsPressed
        case clearAllChatsSuccess
        case clearAllChatsFailed(error: Error)
        case refreshDataPressed

        var eventName: String {
            switch self {
            case .screenAppeared: "AdminView_Screen_Appeared"
            case .loadDataFailed: "AdminView_LoadData_Failed"
            case .clearAllChatsPressed: "AdminView_ClearAllChats_Pressed"
            case .clearAllChatsSuccess: "AdminView_ClearAllChats_Success"
            case .clearAllChatsFailed: "AdminView_ClearAllChats_Failed"
            case .refreshDataPressed: "AdminView_RefreshData_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadDataFailed(error: let error),
                 .clearAllChatsFailed(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadDataFailed, .clearAllChatsFailed:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
