//
//  ChatViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class ChatViewModel {
    
    private let chatUseCase: ChatUseCaseProtocol
    
    private(set) var chat: ChatModel?
    private(set) var chatMessages: [ChatMessageModel] = []
    private(set) var avatar: AvatarModel?
    private(set) var currentUser: UserModel?
    private(set) var isGeneratingResponse: Bool = false
    private(set) var typingIndicatorMessage: ChatMessageModel?
    private(set) var messageListener: ListenerRegistration?
    
    var textFieldText: String = ""
    var scrollPosition: String?
    var showAlert: AnyAppAlert?
    var showChatSettings: AnyAppAlert?
    var showProfileModal: Bool = false
    var showPaywall: Bool = false
    
    init(chatUseCase: ChatUseCaseProtocol) {
        self.chatUseCase = chatUseCase
    }
}

// MARK: - Load
extension ChatViewModel {
    
    func loadAvatar(avatarId: String) async {
        chatUseCase.trackEvent(event: Event.loadAvatarStart)
        do {
            avatar = try await chatUseCase.getAvatar(id: avatarId)
            guard let avatar else { return }
            chatUseCase
                .trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            try? await chatUseCase.addRecentAvatar(avatar: avatar)
        } catch {
            chatUseCase
                .trackEvent(
                    event: Event.loadAvatarFail(error: error)
                )
        }
    }
    
    func loadChat(avatarId: String) async {
        chatUseCase.trackEvent(event: Event.loadChatStart)
        do {
            let userId = try chatUseCase.getAuthId()
            chat = try await chatUseCase
                .getChat(userId: userId, avatarId: avatarId)
            chatUseCase
                .trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            chatUseCase
                .trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func listenToChatMessages() async {
        chatUseCase.trackEvent(event: Event.loadMessagesStart)
        do {
            let chatId = try getChatId()
            
            for try await value in chatUseCase.streamChatMessages(chatId: chatId) {
                chatMessages = value
                    .sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            chatUseCase
                .trackEvent(event: Event.loadMessagesFail(error: error))
        }
    }
    
    func onViewFirstAppear(chat: ChatModel?) {
        currentUser = chatUseCase.currentUser
        self.chat = chat
    }
    
    func onProfileModalXmarksTapped() {
        showProfileModal = false
    }
    
    func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let userId = try chatUseCase.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: userId) else { return }
                
                try await chatUseCase
                    .markChatMessagesAsSeen(
                        chatId: chatId,
                        messageId: message.id,
                        userId: userId
                    )
            } catch {
                chatUseCase
                    .trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
}

// MARK: - Action
extension ChatViewModel {
    // swiftlint:disable function_body_length
    func onSendMessageTapped(avatarId: String) {
        guard !textFieldText.isEmpty else { return }
        
        let content = textFieldText
        chatUseCase
            .trackEvent(
                event: Event.sendMessageStart(chat: chat, avatar: avatar)
            )
        
        Task {
            do {
                // Show paywall if needed
                if !chatUseCase.isPremium && chatMessages.count >= 3 {
                    showPaywall = true
                    return
                }
                
                // Get userId
                let userId = try chatUseCase.getAuthId()
                
                // Validate textField text
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                // if chat is nil, then create a new chat
                if chat == nil {
                    chat = try await createNewChat(
                        userId: userId,
                        avatarId: avatarId
                    )
                }
                
                // if there is no chatm throw error (shold never happen)
                guard let chat else {
                    throw ChatViewEror.failedToCreateNewChat
                }
                
                // create User Chat
                let newChatMessage = AIChatModel(role: .user, message: content)
                let message = ChatMessageModel.newUserMessage(
                    chatId: chat.id,
                    userId: userId,
                    message: newChatMessage
                )
                
                // upload user chat
                try await chatUseCase
                    .addChatMessage(
                        message: message
                    )
                chatUseCase
                    .trackEvent(
                        event: Event
                            .sendMessageSent(
                                chat: chat,
                                avatar: avatar,
                                message: message
                            )
                    )
                // clear text field & scroll to bottom
                
                // Show fake typing message
                let typingMessage = ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: chat.id,
                    authorId: avatarId,
                    content: AIChatModel(role: .assistant, message: "💬"),
                    seenByIds: [],
                    dateCreated: .now
                )
                typingIndicatorMessage = typingMessage
                scrollPosition = typingMessage.id
                textFieldText = ""
                
                // Generate AI response
                isGeneratingResponse = true
                var aiChats = chatMessages.compactMap({ $0.content })
                if let avatarDescription = avatar?.characterDescription {
                    let systemMessage: AIChatModel = AIChatModel(
                        role: .system,
                        message: "You are a \(avatarDescription) with the intelligence of an AI. We are having a VERY casual conversation. You are my friend."
                    )
                    aiChats.insert(systemMessage, at: 0)
                }
                let response = try await chatUseCase.generateText(
                    chats: aiChats
                )
                typingIndicatorMessage = nil
                
                // create AI Chat
                let newAIMessage = ChatMessageModel.newUAIMessage(
                    chatId: chat.id,
                    avatarId: avatarId,
                    message: response
                )
                chatUseCase
                    .trackEvent(
                        event: Event
                            .sendMessageResponse(
                                chat: chat,
                                avatar: avatar,
                                message: newAIMessage
                            )
                    )
                
                // upload AI chat
                try await chatUseCase
                    .addChatMessage(
                        message: newAIMessage
                    )
                chatUseCase
                    .trackEvent(
                        event: Event
                            .sendMessageResponseSent(
                                chat: chat,
                                avatar: avatar,
                                message: newAIMessage
                            )
                    )
                isGeneratingResponse = false
                
            } catch let error {
                showAlert = AnyAppAlert(error: error)
                chatUseCase
                    .trackEvent(event: Event.sendMessageFail(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    // swiftlint:enable function_body_length
    
    func onChatSettingsTapped(
        onDidDeleteChat: @escaping @MainActor () -> Void
    ) {
        chatUseCase.trackEvent(event: Event.chatSettingsTapped)
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?"
        ) {
            AnyView(
                Group {
                    Button("Report User / Chat", role: .destructive) {
                        self.onReportChatTapped()
                    }
                    
                    Button("Delete Chat", role: .destructive) {
                        self.onDeleteChatTapped(onDidDeleteChat: onDidDeleteChat)
                    }
                }
            )
        }
    }
    
    func onReportChatTapped() {
        chatUseCase.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let chatId = try getChatId()
                let userId = try chatUseCase.getAuthId()
                try await chatUseCase.reportChat(chatId: chatId, userId: userId)
                chatUseCase.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = AnyAppAlert(
                    title: "🚨 Reported! 🚨",
                    subtitle: "We will look into this as soon as possible. You may leave the chat at any time. Thanks for bringing this to our attention!"
                )
            } catch {
                chatUseCase
                    .trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please try again later."
                )
            }
        }
    }
    
    func onDeleteChatTapped(onDidDeleteChat: @escaping () -> Void) {
        chatUseCase.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await chatUseCase.deleteChat(chatId: chatId)
                chatUseCase.trackEvent(event: Event.deleteChatSuccess)
                onDidDeleteChat()
            } catch {
                chatUseCase
                    .trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please try again later."
                )
            }
        }
    }
    
    func onAvatarImageTapped() {
        chatUseCase
            .trackEvent(event: Event.avatarImageTapped(avatar: avatar))
        showProfileModal = true
    }
    
    func onDisappear() {
        messageListener?.remove()
    }
}

// MARK: - helper func
extension ChatViewModel {
    
    func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewEror.failedToCreateNewChat
        }
        return chat.id
    }
    
    enum ChatViewEror: Error {
        case failedToCreateNewChat
    }
    
    func createNewChat(userId: String, avatarId: String) async throws -> ChatModel {
        chatUseCase.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(
            userId: userId,
            avatarId: avatarId
        )
        try await chatUseCase.createNewChat(chat: newChat)
        
        defer {
            Task {
                await listenToChatMessages()
            }
        }
        
        return newChat
    }
    
    func messageIsDelayed(message: ChatMessageModel) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated
        
        guard let index = chatMessages
            .firstIndex(where: { $0.id == message.id}),
              chatMessages.indices.contains(index - 1)
        else {
            return false
        }
        
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        let threshold: TimeInterval = 60 * 45
        
        return timeDiff > threshold
    }
    
    func messageIsCurrentUser(message: ChatMessageModel) -> Bool {
        message.authorId == chatUseCase.auth?.uid
    }
}

// MARK: - Event
private extension ChatViewModel {
    
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatar: AvatarModel?)
        case loadAvatarFail(error: Error)
        
        case loadChatStart
        case loadChatSuccess(chat: ChatModel?)
        case loadChatFail(error: Error)
        
        case loadMessagesStart
        case loadMessagesFail(error: Error)
        
        case messageSeenFail(error: Error)
        
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessageFail(error: Error)
        
        case sendMessagePaywall(chat: ChatModel?, avatar: AvatarModel?)
        
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        
        case createChatStart
        case chatSettingsTapped
        case reportChatStart
        case reportChatSuccess
        case reportChatFail(error: Error)
        case deleteChatStart
        case deleteChatSuccess
        case deleteChatFail(error: Error)
        case avatarImageTapped(avatar: AvatarModel?)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart:
                "\(ScreenName.from(ChatView.self))_LoadAvatar_Start"
            case .loadAvatarSuccess:
                "\(ScreenName.from(ChatView.self))_LoadAvatar_Success"
            case .loadAvatarFail:
                "\(ScreenName.from(ChatView.self))_LoadAvatar_Fail"
            case .loadChatStart:
                "\(ScreenName.from(ChatView.self))_LoadChat_Start"
            case .loadChatSuccess:
                "\(ScreenName.from(ChatView.self))_LoadChat_Success"
            case .loadChatFail:
                "\(ScreenName.from(ChatView.self))_LoadChat_Fail"
            case .loadMessagesStart:
                "\(ScreenName.from(ChatView.self))_LoadMessages_Start"
            case .loadMessagesFail:
                "\(ScreenName.from(ChatView.self))_LoadMessages_Fail"
            case .messageSeenFail:
                "\(ScreenName.from(ChatView.self))_MessageSeen_Fail"
            case .sendMessageStart:
                "\(ScreenName.from(ChatView.self))_SendMessage_Start"
            case .sendMessageFail:
                "\(ScreenName.from(ChatView.self))_SendMessage_Fail"
            case .sendMessagePaywall:
                "\(ScreenName.from(ChatView.self))_SendMessage_Paywall"
            case .sendMessageSent:
                "\(ScreenName.from(ChatView.self))_SendMessage_Sent"
            case .sendMessageResponse:
                "\(ScreenName.from(ChatView.self))_SendMessage_Response"
            case .sendMessageResponseSent:
                "\(ScreenName.from(ChatView.self))_SendMessage_ResponseSent"
            case .createChatStart:
                "\(ScreenName.from(ChatView.self))_CreateChat_Start"
            case .chatSettingsTapped:
                "\(ScreenName.from(ChatView.self))_ChatSettings_Tapped"
            case .reportChatStart:
                "\(ScreenName.from(ChatView.self))_ReportChat_Start"
            case .reportChatSuccess:
                "\(ScreenName.from(ChatView.self))_ReportChat_Success"
            case .reportChatFail:
                "\(ScreenName.from(ChatView.self))_ReportChat_Fail"
            case .deleteChatStart:
                "\(ScreenName.from(ChatView.self))_DeleteChat_Start"
            case .deleteChatSuccess:
                "\(ScreenName.from(ChatView.self))_DeleteChat_Success"
            case .deleteChatFail:
                "\(ScreenName.from(ChatView.self))_DeleteChat_Fail"
            case .avatarImageTapped:
                "\(ScreenName.from(ChatView.self))_AvatarImage_Tapped"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .loadAvatarSuccess(avatar: let avatar),
                    .avatarImageTapped(avatar: let avatar):
                return avatar?.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .loadAvatarFail(error: let error),
                    .loadChatFail(error: let error),
                    .loadMessagesFail(error: let error),
                    .messageSeenFail(error: let error),
                    .sendMessageFail(error: let error),
                    .reportChatFail(error: let error),
                    .deleteChatFail(error: let error):
                return error.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar),
                    .sendMessagePaywall(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters ?? [:])
                dict.merge(message.eventParameters)
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarFail,
                    .messageSeenFail,
                    .reportChatFail,
                    .deleteChatFail:
                    .severe
            case .loadChatFail,
                    .sendMessageFail,
                    .loadMessagesFail:
                    .warning
            default:
                    .analytic
            }
        }
    }
}
