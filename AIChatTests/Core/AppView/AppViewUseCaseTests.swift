//
//  AppViewUseCaseTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.12.2025.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct AppViewUseCaseTests {

    // MARK: - Initialization Tests

    @Test("AppViewUseCase Initializes Successfully With All Dependencies")
    func testAppViewUseCaseInitializesSuccessfully() {
        let container = createTestContainer()
        let useCase = AppViewUseCase(container: container)

        #expect(useCase != nil)
    }

    // MARK: - ShowTabBar Tests

    @Test("ShowTabBar Returns True When AppState ShowTabBar Is True")
    func testShowTabBarReturnsTrueWhenAppStateShowTabBarIsTrue() {
        let container = createTestContainer()
        guard let appState = container.resolve(AppState.self) else {
            Issue.record("AppState not found in container")
            return
        }

        appState.showTabBar = true

        let useCase = AppViewUseCase(container: container)

        #expect(useCase.showTabBar == true)
    }

    @Test("ShowTabBar Returns False When AppState ShowTabBar Is False")
    func testShowTabBarReturnsFalseWhenAppStateShowTabBarIsFalse() {
        let container = createTestContainer()
        guard let appState = container.resolve(AppState.self) else {
            Issue.record("AppState not found in container")
            return
        }

        appState.showTabBar = false

        let useCase = AppViewUseCase(container: container)

        #expect(useCase.showTabBar == false)
    }

    // MARK: - Auth Tests

    @Test("Auth Returns Auth Info From AuthManager")
    func testAuthReturnsAuthInfoFromAuthManager() {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager else {
            Issue.record("AuthManager not found or wrong type in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "test-123", providerUserId: "provider-123", provider: .apple)
        authManager.setAuth(mockAuth)

        let useCase = AppViewUseCase(container: container)

        #expect(useCase.auth?.userId == "test-123")
        #expect(useCase.auth?.provider == .apple)
    }

    @Test("Auth Returns Nil When No Auth Set")
    func testAuthReturnsNilWhenNoAuthSet() {
        let container = createTestContainer()
        let useCase = AppViewUseCase(container: container)

        #expect(useCase.auth == nil)
    }

    // MARK: - Sign In Anonymously Tests

    @Test("SignInAnonymously Returns Auth And IsNewUser")
    func testSignInAnonymouslyReturnsAuthAndIsNewUser() async throws {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager else {
            Issue.record("AuthManager not found or wrong type in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "anon-123", providerUserId: "anon-provider-123", provider: .anonymous)
        authManager.setMockSignInResult(auth: mockAuth, isNewUser: true)

        let useCase = AppViewUseCase(container: container)
        let result = try await useCase.signInAnonymously()

        #expect(result.user.userId == "anon-123")
        #expect(result.user.provider == .anonymous)
        #expect(result.isNewUser == true)
    }

    @Test("SignInAnonymously Returns IsNewUser False For Returning User")
    func testSignInAnonymouslyReturnsIsNewUserFalseForReturningUser() async throws {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) as? MockAuthManager else {
            Issue.record("AuthManager not found or wrong type in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "anon-456", providerUserId: "anon-provider-456", provider: .anonymous)
        authManager.setMockSignInResult(auth: mockAuth, isNewUser: false)

        let useCase = AppViewUseCase(container: container)
        let result = try await useCase.signInAnonymously()

        #expect(result.user.userId == "anon-456")
        #expect(result.isNewUser == false)
    }

    // MARK: - Log In Tests

    @Test("LogIn Calls UserManager LogIn With Correct Parameters")
    func testLogInCallsUserManagerLogInWithCorrectParameters() async throws {
        let container = createTestContainer()
        guard let userManager = container.resolve(UserManager.self) as? MockUserManager else {
            Issue.record("UserManager not found or wrong type in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "user-789", providerUserId: "provider-789", provider: .google)

        let useCase = AppViewUseCase(container: container)
        try await useCase.logIn(auth: mockAuth, isNewUser: true)

        #expect(userManager.lastLogInAuth?.userId == "user-789")
        #expect(userManager.lastLogInIsNewUser == true)
    }

    @Test("LogIn With IsNewUser False")
    func testLogInWithIsNewUserFalse() async throws {
        let container = createTestContainer()
        guard let userManager = container.resolve(UserManager.self) as? MockUserManager else {
            Issue.record("UserManager not found or wrong type in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "user-999", providerUserId: "provider-999", provider: .apple)

        let useCase = AppViewUseCase(container: container)
        try await useCase.logIn(auth: mockAuth, isNewUser: false)

        #expect(userManager.lastLogInAuth?.userId == "user-999")
        #expect(userManager.lastLogInIsNewUser == false)
    }

    // MARK: - Track Event Tests

    @Test("Track Event Does Not Crash")
    func testTrackEventDoesNotCrash() {
        let container = createTestContainer()
        let useCase = AppViewUseCase(container: container)

        let event = MockLoggableEvent(name: "app_view_event")

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    @Test("Track Event With Parameters Does Not Crash")
    func testTrackEventWithParametersDoesNotCrash() {
        let container = createTestContainer()
        let useCase = AppViewUseCase(container: container)

        let parameters: [String: Any] = ["screen": "app_view", "action": "login"]
        let event = MockLoggableEvent(name: "user_action", parameters: parameters)

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    // MARK: - Integration Tests

    @Test("AppState Changes Reflect In ShowTabBar Property")
    func testAppStateChangesReflectInShowTabBarProperty() {
        let container = createTestContainer()
        guard let appState = container.resolve(AppState.self) else {
            Issue.record("AppState not found in container")
            return
        }

        let useCase = AppViewUseCase(container: container)

        appState.showTabBar = false
        #expect(useCase.showTabBar == false)

        appState.showTabBar = true
        #expect(useCase.showTabBar == true)
    }

    // MARK: - Helper Methods

    private func createTestContainer() -> DependencyContainer {
        let container = DependencyContainer()

        // Register mock managers
        let authManager = MockAuthManager()
        let userManager = MockUserManager()
        let appState = AppState()
        let logManager = LogManager(services: [MockLogService()])

        container.register(AuthManager.self, authManager)
        container.register(UserManager.self, userManager)
        container.register(AppState.self, appState)
        container.register(LogManager.self, logManager)

        return container
    }
}

// MARK: - Mock Managers

final class MockAuthManager: AuthManager {
    private var mockAuth: UserAuthInfo?
    private var mockSignInResult: (auth: UserAuthInfo, isNewUser: Bool)?

    func setAuth(_ auth: UserAuthInfo) {
        mockAuth = auth
    }

    func setMockSignInResult(auth: UserAuthInfo, isNewUser: Bool) {
        mockSignInResult = (auth, isNewUser)
    }

    override var auth: UserAuthInfo? {
        mockAuth
    }

    override func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        guard let result = mockSignInResult else {
            throw NSError(domain: "MockAuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock sign in result not set"])
        }
        return result
    }
}

final class MockUserManager: UserManager {
    var lastLogInAuth: UserAuthInfo?
    var lastLogInIsNewUser: Bool?

    override func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        lastLogInAuth = auth
        lastLogInIsNewUser = isNewUser
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
