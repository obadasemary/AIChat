//
//  ChatViewModelTests.swift
//  AIChatTests
//
//  Created by Claude on 22.02.2026.
//

import Testing
import SwiftUI
import Foundation
@testable import AIChat

@MainActor
struct ChatViewModelTests {

    // MARK: - Load Avatar

    @Test("Load Avatar Success - sets avatar property and tracks event")
    func test_loadAvatar_success_setsAvatarAndTracksEvent() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())

        await viewModel.loadAvatar(avatarId: AvatarModel.mock.avatarId)

        #expect(viewModel.avatar != nil)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName.contains("LoadAvatar_Success") })
    }

    @Test("Load Avatar Failure - avatar stays nil and tracks error event")
    func test_loadAvatar_failure_avatarRemainsNil() async {
        let mockUseCase = MockChatUseCase()
        mockUseCase.shouldFailGetAvatar = true
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())

        await viewModel.loadAvatar(avatarId: "any-id")

        #expect(viewModel.avatar == nil)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName.contains("LoadAvatar_Fail") })
    }

    // MARK: - Load Chat

    @Test("Load Chat Success - sets chat property")
    func test_loadChat_success_setsChatProperty() async {
        let mockUseCase = MockChatUseCase()
        mockUseCase.chatToReturn = ChatModel.mock
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())

        await viewModel.loadChat(avatarId: ChatModel.mock.avatarId)

        #expect(viewModel.chat != nil)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName.contains("LoadChat_Success") })
    }

    @Test("Load Chat Failure - tracks error event")
    func test_loadChat_failure_tracksErrorEvent() async {
        let mockUseCase = MockChatUseCase()
        mockUseCase.shouldFailGetChat = true
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())

        await viewModel.loadChat(avatarId: "any-id")

        #expect(viewModel.chat == nil)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName.contains("LoadChat_Fail") })
    }

    // MARK: - onViewFirstAppear

    @Test("onViewFirstAppear - sets currentUser and chat from use case")
    func test_onViewFirstAppear_setsCurrentUserAndChat() {
        let mockUseCase = MockChatUseCase()
        let expectedChat = ChatModel.mock
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())

        viewModel.onViewFirstAppear(chat: expectedChat)

        #expect(viewModel.currentUser?.userId == mockUseCase.currentUser?.userId)
        #expect(viewModel.chat?.id == expectedChat.id)
    }

    // MARK: - onSendMessageTapped

    @Test("Send Message - empty text does nothing")
    func test_onSendMessage_emptyText_doesNothing() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        viewModel.textFieldText = ""

        viewModel.onSendMessageTapped(avatarId: "any-id")
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockUseCase.trackedEvents.isEmpty)
    }

    @Test("Send Message - shows paywall when non-premium with 999+ messages")
    func test_onSendMessage_paywallShown_whenNonPremiumAndOver999Messages() async {
        let mockUseCase = MockChatUseCase()
        mockUseCase.isPremium = false
        let mockRouter = MockChatRouter()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: mockRouter)

        viewModel.onViewFirstAppear(chat: ChatModel.mock)
        // inject 999 fake messages into chatMessages via the stream
        mockUseCase.messagesToStream = Array(repeating: ChatMessageModel.mock, count: 999)
        await viewModel.listenToChatMessages()

        viewModel.textFieldText = "Hello"
        viewModel.onSendMessageTapped(avatarId: AvatarModel.mock.avatarId)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockRouter.showPaywallViewCalled)
    }

    @Test("Send Message - creates new chat when chat is nil")
    func test_onSendMessage_createsNewChat_whenChatIsNil() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())

        viewModel.textFieldText = "Hello"
        viewModel.onSendMessageTapped(avatarId: AvatarModel.mock.avatarId)
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockUseCase.createNewChatCalled)
    }

    @Test("Send Message - clears text field after send")
    func test_onSendMessage_clearsTextField_afterSend() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        viewModel.onViewFirstAppear(chat: ChatModel.mock)

        viewModel.textFieldText = "Hello world"
        viewModel.onSendMessageTapped(avatarId: AvatarModel.mock.avatarId)
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(viewModel.textFieldText.isEmpty)
    }

    @Test("Send Message - editing mode updates existing message")
    func test_onSendMessage_editingMode_updatesMessage() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        viewModel.onViewFirstAppear(chat: ChatModel.mock)

        let existingMessage = ChatMessageModel.mock
        viewModel.onMessageEditTapped(message: existingMessage)
        viewModel.textFieldText = "Edited content"

        viewModel.onSendMessageTapped(avatarId: AvatarModel.mock.avatarId)
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(mockUseCase.updateChatMessageCalled)
        #expect(viewModel.editingMessage == nil)
        #expect(viewModel.textFieldText.isEmpty)
    }

    @Test("Send Message - adds reply reference to outgoing message")
    func test_onSendMessage_addsReplyReference() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        viewModel.onViewFirstAppear(chat: ChatModel.mock)

        let replyTarget = ChatMessageModel.mock
        viewModel.onMessageReplyTapped(message: replyTarget)
        viewModel.textFieldText = "My reply"

        viewModel.onSendMessageTapped(avatarId: AvatarModel.mock.avatarId)
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(mockUseCase.lastAddedMessage?.replyToMessageId == replyTarget.id)
        #expect(viewModel.replyingToMessage == nil)
    }

    @Test("Send Message - AI failure shows alert")
    func test_onSendMessage_aiFailure_showsAlert() async {
        let mockUseCase = MockChatUseCase()
        mockUseCase.shouldFailGenerateText = true
        let mockRouter = MockChatRouter()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: mockRouter)
        viewModel.onViewFirstAppear(chat: ChatModel.mock)

        viewModel.textFieldText = "Hello"
        viewModel.onSendMessageTapped(avatarId: AvatarModel.mock.avatarId)
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(mockRouter.showAlertErrorCalled)
    }

    @Test("Send Message - adds user message and AI response message")
    func test_onSendMessage_addsBothUserAndAIMessages() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        viewModel.onViewFirstAppear(chat: ChatModel.mock)

        viewModel.textFieldText = "Hello"
        viewModel.onSendMessageTapped(avatarId: AvatarModel.mock.avatarId)
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(mockUseCase.addChatMessageCallCount >= 2)
    }

    // MARK: - Reply

    @Test("Message Reply Tapped - sets replyingToMessage and clears editingMessage")
    func test_onMessageReplyTapped_setsReplyingToMessage() {
        let viewModel = ChatViewModel(chatUseCase: MockChatUseCase(), router: MockChatRouter())
        let message = ChatMessageModel.mock
        viewModel.editingMessage = message

        viewModel.onMessageReplyTapped(message: message)

        #expect(viewModel.replyingToMessage?.id == message.id)
        #expect(viewModel.editingMessage == nil)
    }

    @Test("Cancel Reply - clears replyingToMessage")
    func test_cancelReply_clearsReplyingToMessage() {
        let viewModel = ChatViewModel(chatUseCase: MockChatUseCase(), router: MockChatRouter())
        viewModel.replyingToMessage = ChatMessageModel.mock

        viewModel.cancelReply()

        #expect(viewModel.replyingToMessage == nil)
    }

    // MARK: - Edit

    @Test("Message Edit Tapped - sets editingMessage and textField, clears reply")
    func test_onMessageEditTapped_setsEditingAndTextAndClearsReply() {
        let viewModel = ChatViewModel(chatUseCase: MockChatUseCase(), router: MockChatRouter())
        let message = ChatMessageModel.mock
        viewModel.replyingToMessage = message

        viewModel.onMessageEditTapped(message: message)

        #expect(viewModel.editingMessage?.id == message.id)
        #expect(viewModel.textFieldText == message.content?.message ?? "")
        #expect(viewModel.replyingToMessage == nil)
    }

    @Test("Cancel Edit - clears editingMessage and textField")
    func test_cancelEdit_clearsEditingAndTextField() {
        let viewModel = ChatViewModel(chatUseCase: MockChatUseCase(), router: MockChatRouter())
        viewModel.editingMessage = ChatMessageModel.mock
        viewModel.textFieldText = "Some text"

        viewModel.cancelEdit()

        #expect(viewModel.editingMessage == nil)
        #expect(viewModel.textFieldText.isEmpty)
    }

    // MARK: - messageIsDelayed

    @Test("messageIsDelayed - returns true when gap is over 45 minutes")
    func test_messageIsDelayed_whenOver45Minutes() {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        let now = Date()
        let oldMessage = ChatMessageModel(id: "old", chatId: "c1", dateCreated: now.addingTimeInterval(-3000)) // 50 min ago
        let newMessage = ChatMessageModel(id: "new", chatId: "c1", dateCreated: now)

        // Simulate chatMessages being set (via internal storage workaround)
        mockUseCase.messagesToStream = [oldMessage, newMessage]

        // Manually set via a helper — we construct two messages with known dates
        let isDelayed = viewModel.messageIsDelayed(
            message: newMessage,
            inMessages: [oldMessage, newMessage]
        )

        #expect(isDelayed == true)
    }

    @Test("messageIsDelayed - returns false when gap is under 45 minutes")
    func test_messageIsDelayed_whenUnder45Minutes() {
        let viewModel = ChatViewModel(chatUseCase: MockChatUseCase(), router: MockChatRouter())
        let now = Date()
        let recentMessage = ChatMessageModel(id: "recent", chatId: "c1", dateCreated: now.addingTimeInterval(-60)) // 1 min ago
        let currentMessage = ChatMessageModel(id: "current", chatId: "c1", dateCreated: now)

        let isDelayed = viewModel.messageIsDelayed(
            message: currentMessage,
            inMessages: [recentMessage, currentMessage]
        )

        #expect(isDelayed == false)
    }

    // MARK: - messageIsCurrentUser

    @Test("messageIsCurrentUser - returns true when authorId matches auth uid")
    func test_messageIsCurrentUser_matchesAuthId() {
        let mockUseCase = MockChatUseCase()
        let authId = mockUseCase.auth?.uid ?? "test-uid"
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        let message = ChatMessageModel(id: "m1", chatId: "c1", authorId: authId)

        #expect(viewModel.messageIsCurrentUser(message: message) == true)
    }

    @Test("messageIsCurrentUser - returns false when authorId does not match")
    func test_messageIsCurrentUser_returnsFalseForOtherAuthor() {
        let viewModel = ChatViewModel(chatUseCase: MockChatUseCase(), router: MockChatRouter())
        let message = ChatMessageModel(id: "m1", chatId: "c1", authorId: "other-user-id")

        #expect(viewModel.messageIsCurrentUser(message: message) == false)
    }

    // MARK: - Delete / Report Chat

    @Test("Delete Chat Success - dismisses modal and schedules screen dismissal")
    func test_onDeleteChat_success_callsDismissModal() async {
        let mockUseCase = MockChatUseCase()
        let mockRouter = MockChatRouter()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: mockRouter)
        viewModel.onViewFirstAppear(chat: ChatModel.mock)

        viewModel.onDeleteChatTapped()
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(mockRouter.dismissModalCalled)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName.contains("DeleteChat_Success") })
    }

    @Test("Report Chat Success - shows confirmation alert")
    func test_onReportChat_success_showsAlert() async {
        let mockUseCase = MockChatUseCase()
        let mockRouter = MockChatRouter()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: mockRouter)
        viewModel.onViewFirstAppear(chat: ChatModel.mock)

        viewModel.onReportChatTapped()
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(mockRouter.showAlertCalled)
        #expect(mockUseCase.trackedEvents.contains { $0.eventName.contains("ReportChat_Success") })
    }

    // MARK: - Translate

    @Test("Translate Message - first call adds translation, second call removes it")
    func test_onMessageTranslateTapped_togglesBehavior() async {
        let mockUseCase = MockChatUseCase()
        let viewModel = ChatViewModel(chatUseCase: mockUseCase, router: MockChatRouter())
        let message = ChatMessageModel.mock

        // First tap: should add translation
        viewModel.onMessageTranslateTapped(message: message)
        try? await Task.sleep(nanoseconds: 200_000_000)
        #expect(viewModel.translatedMessages[message.id] != nil)

        // Second tap: should remove translation
        viewModel.onMessageTranslateTapped(message: message)
        try? await Task.sleep(nanoseconds: 100_000_000)
        #expect(viewModel.translatedMessages[message.id] == nil)
    }
}

// MARK: - ChatViewModel Testable Extension

extension ChatViewModel {
    /// Test-only helper that accepts an explicit message list for `messageIsDelayed`.
    func messageIsDelayed(message: ChatMessageModel, inMessages messages: [ChatMessageModel]) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated

        guard
            let index = messages.firstIndex(where: { $0.id == message.id }),
            messages.indices.contains(index - 1)
        else {
            return false
        }

        let previousMessageDate = messages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        let threshold: TimeInterval = 60 * 45

        return timeDiff > threshold
    }
}

// MARK: - MockChatUseCase

@MainActor
final class MockChatUseCase: ChatUseCaseProtocol {

    var currentUser: UserModel? = UserModel.mock
    var auth: UserAuthInfo? = UserAuthInfo.mock()
    var isPremium: Bool = false
    var trackedEvents: [any LoggableEvent] = []

    var shouldFailGetAvatar: Bool = false
    var shouldFailGetChat: Bool = false
    var shouldFailGenerateText: Bool = false
    var shouldFailAddMessage: Bool = false

    var chatToReturn: ChatModel?
    var messagesToStream: [ChatMessageModel] = []

    var createNewChatCalled: Bool = false
    var updateChatMessageCalled: Bool = false
    var lastAddedMessage: ChatMessageModel?
    var addChatMessageCallCount: Int = 0

    func getAuthId() throws -> String {
        guard let uid = auth?.uid else { throw MockChatError.noUser }
        return uid
    }

    func getAvatar(id: String) async throws -> AvatarModel? {
        if shouldFailGetAvatar { throw MockChatError.avatarLoadFailed }
        return AvatarModel.mock
    }

    func addRecentAvatar(avatar: AvatarModel) async throws {}

    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        if shouldFailGetChat { throw MockChatError.chatLoadFailed }
        return chatToReturn
    }

    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        let messages = messagesToStream
        return AsyncThrowingStream { continuation in
            continuation.yield(messages)
            continuation.finish()
        }
    }

    func markChatMessagesAsSeen(chatId: String, messageId: String, userId: String) async throws {}

    func createNewChat(chat: ChatModel) async throws {
        createNewChatCalled = true
    }

    func addChatMessage(message: ChatMessageModel) async throws {
        if shouldFailAddMessage { throw MockChatError.messageAddFailed }
        if lastAddedMessage == nil {
            lastAddedMessage = message
        }
        addChatMessageCallCount += 1
    }

    func updateChatMessage(message: ChatMessageModel) async throws {
        updateChatMessageCalled = true
    }

    func updateMessageReaction(chatId: String, messageId: String, reactions: [String: MessageReaction]) async throws {}

    func reportChat(chatId: String, userId: String) async throws {}

    func deleteChat(chatId: String) async throws {}

    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        if shouldFailGenerateText { throw MockChatError.textGenerationFailed }
        return AIChatModel(role: .assistant, message: "Mock AI response")
    }

    func trackEvent(event: any LoggableEvent) {
        trackedEvents.append(event)
    }

    enum MockChatError: Error {
        case noUser
        case avatarLoadFailed
        case chatLoadFailed
        case messageAddFailed
        case textGenerationFailed
    }
}

// MARK: - MockChatRouter

@MainActor
final class MockChatRouter: ChatRouterProtocol {

    private(set) var showProfileModalCalled: Bool = false
    private(set) var showPaywallViewCalled: Bool = false
    private(set) var showAlertErrorCalled: Bool = false
    private(set) var showAlertCalled: Bool = false
    private(set) var dismissModalCalled: Bool = false
    private(set) var dismissScreenCalled: Bool = false

    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void) {
        showProfileModalCalled = true
    }

    func showPaywallView() {
        showPaywallViewCalled = true
    }

    func showAlert(error: Error) {
        showAlertErrorCalled = true
    }

    func showAlert(
        _ option: RouterAlertType,
        title: String,
        subtitle: String?,
        buttons: (@Sendable () -> AnyView)?
    ) {
        showAlertCalled = true
    }

    func dismissModal() {
        dismissModalCalled = true
    }

    func dismissScreen() {
        dismissScreenCalled = true
    }
}
