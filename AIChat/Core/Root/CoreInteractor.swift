//
//  CoreInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 25.07.2025.
//

import SwiftUI

@MainActor
struct CoreInteractor {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
    }
}

// MARK: AuthManager
extension CoreInteractor {
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInWithApple()
    }
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInWithGoogle()
    }
    
    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }
}

// MARK: UserManager
extension CoreInteractor {
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: auth, isNewUser: isNewUser)
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        try await userManager
            .markOnboardingCompleteForCurrentUser(
                profileColorHex: profileColorHex
            )
    }
    
    func deleteCurrentUser() async throws {
        try await userManager.deleteCurrentUser()
    }
}

// MARK: AIManager
extension CoreInteractor {
    
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
}

// MARK: AvatarManager
extension CoreInteractor {
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try await avatarManager.addRecentAvatar(avatar: avatar)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try avatarManager.getRecentAvatars()
    }

    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await avatarManager.getAvatar(id: id)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getFeaturedAvatars()
    }

    func getPopularAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuthor(userId: userId)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        try await avatarManager.removeAuthorIdFromAllUserAvatars(userId: userId)
    }
}

// MARK: ChatManager
extension CoreInteractor {
    
    func createNewChat(chat: ChatModel) async throws {
        try await chatManager.createNewChat(chat: chat)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await chatManager.getChat(userId: userId, avatarId: avatarId)
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await chatManager.getAllChats(userId: userId)
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try await chatManager
            .addChatMessage(message: message)
    }
    
    func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await chatManager
            .markChatMessagesAsSeen(
                chatId: chatId,
                messageId: messageId,
                userId: userId
            )
    }
    
    func streamChatMessages(
        chatId: String
    ) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        chatManager
            .streamChatMessages(
                chatId: chatId
            )
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatId: chatId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await chatManager.deleteChat(chatId: chatId)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        try await chatManager.deleteAllChatsForUser(userId: userId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        try await chatManager.reportChat(chatId: chatId, userId: userId)
    }
}

// MARK: LogManager
extension CoreInteractor {
    
    func identify(userId: String, name: String?, email: String?) {
        logManager.identify(userId: userId, name: name, email: email)
    }

    func addUserProperties(dict: [String : Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }

    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
    
    func trackEvent(
        eventName: String,
        parameters: [String : Any]? = nil,
        type: LogType = .analytic
    ) {
        logManager
            .trackEvent(
                eventName: eventName,
                parameters: parameters,
                type: type
            )
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackScreen(event: any LoggableEvent) {
        logManager.trackScreen(event: event)
    }
}

// MARK: PushManager
extension CoreInteractor {
    
    func reuestAuthorization() async throws -> Bool {
        try await pushManager.reuestAuthorization()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotificationForTheNextWeek() {
        pushManager.schedulePushNotificationForTheNextWeek()
    }
}

// MARK: ABTestManager
extension CoreInteractor {
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
    
    var categoryRowTest: CategoryRowTestOption {
        activeTests.categoryRowTest
    }
    
    var createAccountTest: Bool {
        activeTests.createAccountTest
    }
    
    func override(updateTests: ActiveABTests) throws {
        try abTestManager.override(updateTests: updateTests)
    }
}

// MARK: PurchaseManager
extension CoreInteractor {
    
    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }
}
    
// MARK: SHAREDManager
extension CoreInteractor {
    
    func signOut() throws {
        try authManager.signOut()
        userManager.signOut()
    }
}
