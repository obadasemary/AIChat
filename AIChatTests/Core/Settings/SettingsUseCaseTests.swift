//
//  SettingsUseCaseTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.12.2025.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct SettingsUseCaseTests {

    // MARK: - Initialization Tests

    @Test("SettingsUseCase Initializes Successfully With All Dependencies")
    func testSettingsUseCaseInitializesSuccessfully() {
        let container = createTestContainer()
        let useCase = SettingsUseCase(container: container)

        #expect(useCase != nil)
    }

    // MARK: - Auth Tests

    @Test("Auth Returns Auth Info From AuthManager")
    func testAuthReturnsAuthInfoFromAuthManager() {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager else {
            Issue.record("AuthManager not found or wrong type in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "settings-user-123", providerUserId: "provider-123", provider: .google)
        authManager.setAuth(mockAuth)

        let useCase = SettingsUseCase(container: container)

        #expect(useCase.auth?.userId == "settings-user-123")
        #expect(useCase.auth?.provider == .google)
    }

    @Test("Auth Returns Nil When No Auth Set")
    func testAuthReturnsNilWhenNoAuthSet() {
        let container = createTestContainer()
        let useCase = SettingsUseCase(container: container)

        #expect(useCase.auth == nil)
    }

    // MARK: - Sign Out Tests

    @Test("SignOut Calls AuthManager And UserManager SignOut")
    func testSignOutCallsAuthManagerAndUserManagerSignOut() throws {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager,
              let userManager = container.resolve(UserManager.self) as? MockUserManager else {
            Issue.record("Managers not found in container")
            return
        }

        let useCase = SettingsUseCase(container: container)
        try useCase.signOut()

        #expect(authManager.signOutCalled == true)
        #expect(userManager.signOutCalled == true)
    }

    @Test("SignOut Throws When AuthManager Throws")
    func testSignOutThrowsWhenAuthManagerThrows() {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager else {
            Issue.record("AuthManager not found in container")
            return
        }

        authManager.shouldThrowOnSignOut = true

        let useCase = SettingsUseCase(container: container)

        #expect(throws: Error.self) {
            try useCase.signOut()
        }
    }

    // MARK: - Delete Account Tests

    @Test("DeleteAccount Calls All Managers In Sequence")
    func testDeleteAccountCallsAllManagersInSequence() async throws {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager,
              let userManager = container.resolve(UserManager.self) as? MockUserManager,
              let avatarManager = container.resolve(AvatarManager.self) as? MockAvatarManager,
              let chatManager = container.resolve(ChatManager.self) as? MockChatManager,
              let logManager = container.resolve(LogManager.self) else {
            Issue.record("Managers not found in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "delete-user-123", providerUserId: "provider-123", provider: .apple)
        authManager.setAuth(mockAuth)

        let useCase = SettingsUseCase(container: container)
        try await useCase.deleteAccount()

        #expect(chatManager.deleteAllChatsForUserCalled == true)
        #expect(chatManager.lastDeletedUserId == "delete-user-123")
        #expect(avatarManager.removeAuthorIdCalled == true)
        #expect(avatarManager.lastRemovedUserId == "delete-user-123")
        #expect(userManager.deleteCurrentUserCalled == true)
        #expect(authManager.deleteAccountCalled == true)
    }

    @Test("DeleteAccount Calls LogManager DeleteUserProfile")
    func testDeleteAccountCallsLogManagerDeleteUserProfile() async throws {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager,
              let logManager = container.resolve(LogManager.self) as? MockLogManager else {
            Issue.record("Managers not found in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "delete-user-456", providerUserId: "provider-456", provider: .google)
        authManager.setAuth(mockAuth)

        let useCase = SettingsUseCase(container: container)
        try await useCase.deleteAccount()

        #expect(logManager.deleteUserProfileCalled == true)
    }

    @Test("DeleteAccount Throws When No Auth Set")
    func testDeleteAccountThrowsWhenNoAuthSet() async {
        let container = createTestContainer()
        let useCase = SettingsUseCase(container: container)

        await #expect(throws: Error.self) {
            try await useCase.deleteAccount()
        }
    }

    // MARK: - Update AppState Tests

    @Test("UpdateAppState Sets ShowTabBar To True")
    func testUpdateAppStateSetsShowTabBarToTrue() {
        let container = createTestContainer()
        guard let appState = container.resolve(AppState.self) else {
            Issue.record("AppState not found in container")
            return
        }

        let useCase = SettingsUseCase(container: container)
        useCase.updateAppState(showTabBarView: true)

        #expect(appState.showTabBar == true)
    }

    @Test("UpdateAppState Sets ShowTabBar To False")
    func testUpdateAppStateSetsShowTabBarToFalse() {
        let container = createTestContainer()
        guard let appState = container.resolve(AppState.self) else {
            Issue.record("AppState not found in container")
            return
        }

        let useCase = SettingsUseCase(container: container)
        useCase.updateAppState(showTabBarView: false)

        #expect(appState.showTabBar == false)
    }

    @Test("UpdateAppState Can Toggle ShowTabBar Multiple Times")
    func testUpdateAppStateCanToggleShowTabBarMultipleTimes() {
        let container = createTestContainer()
        guard let appState = container.resolve(AppState.self) else {
            Issue.record("AppState not found in container")
            return
        }

        let useCase = SettingsUseCase(container: container)

        useCase.updateAppState(showTabBarView: true)
        #expect(appState.showTabBar == true)

        useCase.updateAppState(showTabBarView: false)
        #expect(appState.showTabBar == false)

        useCase.updateAppState(showTabBarView: true)
        #expect(appState.showTabBar == true)
    }

    // MARK: - Track Event Tests

    @Test("Track Event Does Not Crash")
    func testTrackEventDoesNotCrash() {
        let container = createTestContainer()
        let useCase = SettingsUseCase(container: container)

        let event = MockLoggableEvent(name: "settings_event")

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    @Test("Track Event With Parameters Does Not Crash")
    func testTrackEventWithParametersDoesNotCrash() {
        let container = createTestContainer()
        let useCase = SettingsUseCase(container: container)

        let parameters: [String: Any] = ["setting": "notifications", "enabled": true]
        let event = MockLoggableEvent(name: "setting_changed", parameters: parameters)

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    // MARK: - Helper Methods

    private func createTestContainer() -> DependencyContainer {
        let container = DependencyContainer()

        // Register mock managers
        let authManager = MockAuthManager()
        let userManager = MockUserManager()
        let avatarManager = MockAvatarManager()
        let chatManager = MockChatManager()
        let appState = AppState()
        let logManager = MockLogManager()

        container.register(AuthManager.self, authManager)
        container.register(UserManager.self, userManager)
        container.register(AvatarManager.self, avatarManager)
        container.register(ChatManager.self, chatManager)
        container.register(AppState.self, appState)
        container.register(LogManager.self, logManager)

        return container
    }
}

// MARK: - Mock Managers

final class MockAuthManager: AuthManager {
    private var mockAuth: UserAuthInfo?
    var signOutCalled = false
    var deleteAccountCalled = false
    var shouldThrowOnSignOut = false

    func setAuth(_ auth: UserAuthInfo) {
        mockAuth = auth
    }

    override var auth: UserAuthInfo? {
        mockAuth
    }

    override func getAuthId() throws -> String {
        guard let auth = mockAuth else {
            throw NSError(domain: "MockAuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No auth set"])
        }
        return auth.userId
    }

    override func signOut() throws {
        signOutCalled = true
        if shouldThrowOnSignOut {
            throw NSError(domain: "MockAuthManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sign out failed"])
        }
    }

    override func deleteAccount() async throws {
        deleteAccountCalled = true
    }
}

final class MockUserManager: UserManager {
    var signOutCalled = false
    var deleteCurrentUserCalled = false

    override func signOut() {
        signOutCalled = true
    }

    override func deleteCurrentUser() async throws {
        deleteCurrentUserCalled = true
    }
}

final class MockAvatarManager: AvatarManager {
    var removeAuthorIdCalled = false
    var lastRemovedUserId: String?

    override func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        removeAuthorIdCalled = true
        lastRemovedUserId = userId
    }
}

final class MockChatManager: ChatManager {
    var deleteAllChatsForUserCalled = false
    var lastDeletedUserId: String?

    override func deleteAllChatsForUser(userId: String) async throws {
        deleteAllChatsForUserCalled = true
        lastDeletedUserId = userId
    }
}

final class MockLogManager: LogManager {
    var deleteUserProfileCalled = false

    override func deleteUserProfile() {
        deleteUserProfileCalled = true
    }
}

// MARK: - Mock LoggableEvent

struct MockLoggableEvent: LoggableEvent {
    let name: String
    let parameters: [String: Any]?

    var eventName: String { name }
    var type: LogType { .analytic }

    init(name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
    }
}
