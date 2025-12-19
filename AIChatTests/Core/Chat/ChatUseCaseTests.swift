//
//  ChatUseCaseTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.12.2025.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct ChatUseCaseTests {

    // MARK: - Initialization Tests

    @Test("ChatUseCase Initializes Successfully With All Dependencies")
    func testChatUseCaseInitializesSuccessfully() {
        let container = createTestContainer()
        let useCase = ChatUseCase(container: container)

        #expect(useCase != nil)
    }

    // MARK: - Current User Tests

    @Test("CurrentUser Returns User From UserManager")
    func testCurrentUserReturnsUserFromUserManager() {
        let container = createTestContainer()
        guard let userManager = container.resolve(UserManager.self) else {
            Issue.record("UserManager not found in container")
            return
        }

        let mockUser = UserModel.mock(userId: "test-user-123", displayName: "Test User")
        userManager.setUser(mockUser)

        let useCase = ChatUseCase(container: container)

        #expect(useCase.currentUser?.userId == "test-user-123")
        #expect(useCase.currentUser?.displayName == "Test User")
    }

    @Test("CurrentUser Returns Nil When No User Set")
    func testCurrentUserReturnsNilWhenNoUserSet() {
        let container = createTestContainer()
        let useCase = ChatUseCase(container: container)

        #expect(useCase.currentUser == nil)
    }

    // MARK: - Auth Tests

    @Test("Auth Returns Auth Info From AuthManager")
    func testAuthReturnsAuthInfoFromAuthManager() {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) else {
            Issue.record("AuthManager not found in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "auth-123", providerUserId: "provider-123", provider: .anonymous)
        authManager.setAuth(mockAuth)

        let useCase = ChatUseCase(container: container)

        #expect(useCase.auth?.userId == "auth-123")
        #expect(useCase.auth?.provider == .anonymous)
    }

    @Test("GetAuthId Returns Auth ID Successfully")
    func testGetAuthIdReturnsAuthIdSuccessfully() throws {
        let container = createTestContainer()
        guard let authManager = container.resolve(AuthManager.self) else {
            Issue.record("AuthManager not found in container")
            return
        }

        let mockAuth = UserAuthInfo(userId: "auth-456", providerUserId: "provider-456", provider: .google)
        authManager.setAuth(mockAuth)

        let useCase = ChatUseCase(container: container)
        let authId = try useCase.getAuthId()

        #expect(authId == "auth-456")
    }

    @Test("GetAuthId Throws When No Auth Set")
    func testGetAuthIdThrowsWhenNoAuthSet() {
        let container = createTestContainer()
        let useCase = ChatUseCase(container: container)

        #expect(throws: Error.self) {
            try useCase.getAuthId()
        }
    }

    // MARK: - Premium Status Tests

    @Test("IsPremium Returns True When User Has Active Entitlement")
    func testIsPremiumReturnsTrueWhenUserHasActiveEntitlement() {
        let container = createTestContainer()
        guard let purchaseManager = container.resolve(PurchaseManager.self) else {
            Issue.record("PurchaseManager not found in container")
            return
        }

        purchaseManager.setHasActiveEntitlement(true)

        let useCase = ChatUseCase(container: container)

        #expect(useCase.isPremium == true)
    }

    @Test("IsPremium Returns False When User Has No Active Entitlement")
    func testIsPremiumReturnsFalseWhenUserHasNoActiveEntitlement() {
        let container = createTestContainer()
        let useCase = ChatUseCase(container: container)

        #expect(useCase.isPremium == false)
    }

    // MARK: - Track Event Tests

    @Test("Track Event Does Not Crash")
    func testTrackEventDoesNotCrash() {
        let container = createTestContainer()
        let useCase = ChatUseCase(container: container)

        let event = MockLoggableEvent(name: "chat_test_event")

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    @Test("Track Event With Parameters Does Not Crash")
    func testTrackEventWithParametersDoesNotCrash() {
        let container = createTestContainer()
        let useCase = ChatUseCase(container: container)

        let parameters: [String: Any] = ["chat_id": "123", "message_count": 5]
        let event = MockLoggableEvent(name: "chat_event", parameters: parameters)

        // Should not crash
        useCase.trackEvent(event: event)

        #expect(true)
    }

    // MARK: - Avatar Tests

    @Test("GetAvatar Returns Avatar When Found")
    func testGetAvatarReturnsAvatarWhenFound() async throws {
        let container = createTestContainer()
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            Issue.record("AvatarManager not found in container")
            return
        }

        let mockAvatar = AvatarModel.mock(id: "avatar-123", name: "Test Avatar")
        avatarManager.addMockAvatar(mockAvatar)

        let useCase = ChatUseCase(container: container)
        let avatar = try await useCase.getAvatar(id: "avatar-123")

        #expect(avatar != nil)
        #expect(avatar?.id == "avatar-123")
        #expect(avatar?.name == "Test Avatar")
    }

    @Test("GetAvatar Returns Nil When Not Found")
    func testGetAvatarReturnsNilWhenNotFound() async throws {
        let container = createTestContainer()
        let useCase = ChatUseCase(container: container)

        let avatar = try await useCase.getAvatar(id: "nonexistent")

        #expect(avatar == nil)
    }

    // MARK: - Helper Methods

    private func createTestContainer() -> DependencyContainer {
        let container = DependencyContainer()

        // Register mock managers
        let authManager = MockAuthManager()
        let userManager = MockUserManager()
        let aiManager = MockAIManager()
        let avatarManager = MockAvatarManager()
        let chatManager = MockChatManager()
        let logManager = LogManager(services: [MockLogService()])
        let purchaseManager = MockPurchaseManager()

        container.register(AuthManager.self, authManager)
        container.register(UserManager.self, userManager)
        container.register(AIManager.self, aiManager)
        container.register(AvatarManager.self, avatarManager)
        container.register(ChatManager.self, chatManager)
        container.register(LogManager.self, logManager)
        container.register(PurchaseManager.self, purchaseManager)

        return container
    }
}

// MARK: - Mock Managers

final class MockAuthManager: AuthManager {
    private var mockAuth: UserAuthInfo?

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
}

final class MockUserManager: UserManager {
    private var mockUser: UserModel?

    func setUser(_ user: UserModel) {
        mockUser = user
    }

    override var currentUser: UserModel? {
        mockUser
    }
}

final class MockAIManager: AIManager {
    override func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        AIChatModel(role: .assistant, content: "Mock response")
    }
}

final class MockAvatarManager: AvatarManager {
    private var mockAvatars: [String: AvatarModel] = [:]

    func addMockAvatar(_ avatar: AvatarModel) {
        mockAvatars[avatar.id] = avatar
    }

    override func getAvatar(id: String) async throws -> AvatarModel? {
        mockAvatars[id]
    }

    override func addRecentAvatar(avatar: AvatarModel) async throws {
        // Mock implementation
    }
}

final class MockChatManager: ChatManager {
    override func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        nil
    }

    override func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }

    override func createNewChat(chat: ChatModel) async throws {
        // Mock implementation
    }

    override func addChatMessage(message: ChatMessageModel) async throws {
        // Mock implementation
    }

    override func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws {
        // Mock implementation
    }

    override func reportChat(chatId: String, userId: String) async throws {
        // Mock implementation
    }

    override func deleteChat(chatId: String) async throws {
        // Mock implementation
    }
}

final class MockPurchaseManager: PurchaseManager {
    private var hasActive = false

    func setHasActiveEntitlement(_ value: Bool) {
        hasActive = value
    }

    override var entitlements: PurchaseEntitlements {
        PurchaseEntitlements(hasActiveEntitlement: hasActive)
    }
}

// MARK: - Mock Extensions

extension UserModel {
    static func mock(userId: String = "mock-user", displayName: String = "Mock User") -> UserModel {
        UserModel(
            userId: userId,
            displayName: displayName,
            email: nil,
            profileImagePath: nil,
            dateCreated: Date(),
            isPremium: false
        )
    }
}

extension AvatarModel {
    static func mock(id: String = "mock-avatar", name: String = "Mock Avatar") -> AvatarModel {
        AvatarModel(
            id: id,
            name: name,
            authorId: nil,
            tagline: nil,
            profileImagePath: nil,
            dateCreated: Date()
        )
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
