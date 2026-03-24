//
//  AdminUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import Foundation
import SwiftfulUtilities

@MainActor
protocol AdminUseCaseProtocol {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var isNetworkConnected: Bool { get }
    var networkConnectionType: NetworkConnectionType { get }
    var entitlements: [PurchasedEntitlement] { get }
    var hasActiveEntitlement: Bool { get }
    var activeTests: ActiveABTests { get }

    func canRequestPushAuthorization() async -> Bool
    func getChatCount() async throws -> Int
    func getAvatarCount() async throws -> Int
    func getBookmarkCount() -> Int
    func deleteAllChats() async throws
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class AdminUseCase {

    private let authManager: AuthManager
    private let userManager: UserManager
    private let chatManager: ChatManager
    private let purchaseManager: PurchaseManager
    private let abTestManager: ABTestManager
    private let avatarManager: AvatarManager
    private let bookmarkManager: BookmarkManager
    private let networkMonitor: NetworkMonitorProtocol
    private let pushManager: PushManager
    private let logManager: LogManager

    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for AdminUseCase")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for AdminUseCase")
        }
        guard let chatManager = container.resolve(ChatManager.self) else {
            preconditionFailure("Failed to resolve ChatManager for AdminUseCase")
        }
        guard let purchaseManager = container.resolve(PurchaseManager.self) else {
            preconditionFailure("Failed to resolve PurchaseManager for AdminUseCase")
        }
        guard let abTestManager = container.resolve(ABTestManager.self) else {
            preconditionFailure("Failed to resolve ABTestManager for AdminUseCase")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for AdminUseCase")
        }
        guard let bookmarkManager = container.resolve(BookmarkManager.self) else {
            preconditionFailure("Failed to resolve BookmarkManager for AdminUseCase")
        }
        guard let networkMonitor = container.resolve(NetworkMonitorProtocol.self) else {
            preconditionFailure("Failed to resolve NetworkMonitorProtocol for AdminUseCase")
        }
        guard let pushManager = container.resolve(PushManager.self) else {
            preconditionFailure("Failed to resolve PushManager for AdminUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for AdminUseCase")
        }

        self.authManager = authManager
        self.userManager = userManager
        self.chatManager = chatManager
        self.purchaseManager = purchaseManager
        self.abTestManager = abTestManager
        self.avatarManager = avatarManager
        self.bookmarkManager = bookmarkManager
        self.networkMonitor = networkMonitor
        self.pushManager = pushManager
        self.logManager = logManager
    }
}

extension AdminUseCase: AdminUseCaseProtocol {

    var auth: UserAuthInfo? { authManager.auth }
    var currentUser: UserModel? { userManager.currentUser }
    var isNetworkConnected: Bool { networkMonitor.isConnected }
    var networkConnectionType: NetworkConnectionType { networkMonitor.connectionType }
    var entitlements: [PurchasedEntitlement] { purchaseManager.entitlements }
    var hasActiveEntitlement: Bool { entitlements.hasActiveEntitlement }
    var activeTests: ActiveABTests { abTestManager.activeTests }

    func canRequestPushAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }

    func getChatCount() async throws -> Int {
        guard let userId = auth?.uid else { return 0 }
        let chats = try await chatManager.getAllChats(userId: userId)
        return chats.count
    }

    func getAvatarCount() async throws -> Int {
        guard let userId = auth?.uid else { return 0 }
        let avatars = try await avatarManager.getAvatarsForAuthor(userId: userId)
        return avatars.count
    }

    func getBookmarkCount() -> Int {
        bookmarkManager.getAllBookmarks().count
    }

    func deleteAllChats() async throws {
        guard let userId = auth?.uid else { return }
        try await chatManager.deleteAllChatsForUser(userId: userId)
    }

    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
