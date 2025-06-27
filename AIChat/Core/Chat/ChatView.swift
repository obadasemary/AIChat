//
//  ChatView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.06.2025.
//

import SwiftUI

// swiftlint:disable file_length
struct ChatView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AIManager.self) private var aiManager
    @Environment(LogManager.self) private var logManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    
    var avatarId: String
    @State var chat: ChatModel?
    
    @State private var textFieldText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var scrollPosition: String?
    
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    @State private var isGeneratingResponse: Bool = false
    @State private var typingIndicatorMessage: ChatMessageModel?
    @State private var messageListener: ListenerRegistration?
    
    var body: some View {
        VStack(spacing: .zero) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .anyButton {
                            onChatSettingsTapped()
                        }
                    
                }
            }
        }
        .screenAppearAnalytics(name: ScreenName.from(Self.self))
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
        .task {
            await loadChat()
            await listenToChatMessages()
        }
        .onAppear {
            loadCurrentUser()
        }
        .onDisappear {
            messageListener?.remove()
        }
    }
}

// MARK: - Load
private extension ChatView {
    func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            avatar = try await avatarManager.getAvatar(id: avatarId)
            guard let avatar else { return }
            logManager
                .trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            logManager
                .trackEvent(
                    event: Event.loadAvatarFail(error: error)
                )
        }
    }
    
    func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        do {
            let userId = try authManager.getAuthId()
            chat = try await chatManager
                .getChat(userId: userId, avatarId: avatarId)
            logManager
                .trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager
                .trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func listenToChatMessages() async {
        logManager.trackEvent(event: Event.loadMessagesStart)
        do {
            let chatId = try getChatId()
            
            for try await value in chatManager.streamChatMessages(chatId: chatId) {
                chatMessages = value
                    .sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            logManager
                .trackEvent(event: Event.loadMessagesFail(error: error))
        }
    }
    
    func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription
        ) {
            showProfileModal = false
        }
        .padding()
        .transition(.slide)
    }
    
    func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let userId = try authManager.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: userId) else { return }
                
                try await chatManager
                    .markChatMessagesAsSeen(
                        chatId: chatId,
                        messageId: message.id,
                        userId: userId
                    )
            } catch {
                logManager
                    .trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
}

// MARK: - SectionViews
private extension ChatView {
    var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages + (typingIndicatorMessage.map { [$0] } ?? [])) { message in
                    
                    if messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImageTapped: {
                            onAvatarImageTapped()
                        }
                    )
                    .onAppear {
                        onMessageDidAppear(message: message)
                    }
                    .id(message.id)
                    .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.easeInOut, value: chatMessages.count)
        .animation(.easeInOut, value: scrollPosition)
    }
    
    func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }
    
    var textFieldSection: some View {
        TextField("Type your message...", text: $textFieldText, axis: .vertical)
            .keyboardType(.default)
            .autocorrectionDisabled()
            .focused($isTextFieldFocused)
            .onSubmit {
                isTextFieldFocused = false
                if !textFieldText.isEmpty {
                    onSendMessageTapped()
                }
            }
            .padding(12)
            .padding(.trailing, 60)
            .overlay(alignment: .trailing) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton(.plain) {
                        onSendMessageTapped()
                    }
                    .disabled(textFieldText.isEmpty)
            }
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

// MARK: - Action
private extension ChatView {
    // swiftlint:disable function_body_length
    func onSendMessageTapped() {
        guard !textFieldText.isEmpty else { return }
        
        let content = textFieldText
        logManager
            .trackEvent(
                event: Event.sendMessageStart(chat: chat, avatar: avatar)
            )
        
        Task {
            do {
                // Get userId
                let userId = try authManager.getAuthId()
                
                // Validate textField text
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                // if chat is nil, then create a new chat
                if chat == nil {
                    chat = try await createNewChat(userId: userId)
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
                try await chatManager
                    .addChatMessage(
                        message: message
                    )
                logManager
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
                let response = try await aiManager.generateText(chats: aiChats)
                typingIndicatorMessage = nil
                
                // create AI Chat
                let newAIMessage = ChatMessageModel.newUAIMessage(
                    chatId: chat.id,
                    avatarId: avatarId,
                    message: response
                )
                logManager
                    .trackEvent(
                        event: Event
                            .sendMessageResponse(
                                chat: chat,
                                avatar: avatar,
                                message: newAIMessage
                            )
                    )
                
                // upload AI chat
                try await chatManager
                    .addChatMessage(
                        message: newAIMessage
                    )
                logManager
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
                logManager
                    .trackEvent(event: Event.sendMessageFail(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    // swiftlint:enable function_body_length
    
    func onChatSettingsTapped() {
        logManager.trackEvent(event: Event.chatSettingsTapped)
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?"
        ) {
            AnyView(
                Group {
                    Button("Report User / Chat", role: .destructive) {
                        onReportChatTapped()
                    }
                    
                    Button("Delete Chat", role: .destructive) {
                        onDeleteChatTapped()
                    }
                }
            )
        }
    }
    
    func onReportChatTapped() {
        logManager.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let chatId = try getChatId()
                let userId = try authManager.getAuthId()
                try await chatManager.reportChat(chatId: chatId, userId: userId)
                logManager.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = AnyAppAlert(
                    title: "🚨 Reported! 🚨",
                    subtitle: "We will look into this as soon as possible. You may leave the chat at any time. Thanks for bringing this to our attention!"
                )
            } catch {
                logManager
                    .trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please try again later."
                )
            }
        }
    }
    
    func onDeleteChatTapped() {
        logManager.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                logManager.trackEvent(event: Event.deleteChatSuccess)
                dismiss()
            } catch {
                logManager
                    .trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please try again later."
                )
            }
        }
    }
    
    func onAvatarImageTapped() {
        logManager
            .trackEvent(event: Event.avatarImageTapped(avatar: avatar))
        showProfileModal = true
    }
}

// MARK: - helper func
private extension ChatView {
    func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewEror.failedToCreateNewChat
        }
        return chat.id
    }
    
    enum ChatViewEror: Error {
        case failedToCreateNewChat
    }
    
    func createNewChat(userId: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(
            userId: userId,
            avatarId: avatarId
        )
        try await chatManager.createNewChat(chat: newChat)
        
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
}

// MARK: - Event
private extension ChatView {
    
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
            case .sendMessageStart(chat: let chat, avatar: let avatar):
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

// MARK: - Preview Working Chat
#Preview("Working Chat") {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .previewEnvironment()
    }
}

// MARK: - Preview Slow AI Generation
#Preview("Slow AI Generation") {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .environment(AIManager(service: MockAIServer(delay: 10)))
            .previewEnvironment()
    }
}

// MARK: - Preview Failed AI Generation
#Preview("Failed AI Generation") {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .environment(
                AIManager(
                    service: MockAIServer(
                        delay: 2,
                        showError: true
                    )
                )
            )
            .previewEnvironment()
    }
}
// swiftlint:enable file_length
