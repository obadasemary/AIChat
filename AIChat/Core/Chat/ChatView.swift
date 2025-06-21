//
//  ChatView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.06.2025.
//

import SwiftUI

struct ChatView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AIManager.self) private var aiManager
    
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

// MARK: - load
private extension ChatView {
    func loadAvatar() async {
        do {
            avatar = try await avatarManager.getAvatar(id: avatarId)
            guard let avatar else { return }
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            print("Error loading avatar: \(error)")
        }
    }
    
    func loadChat() async {
        do {
            let userId = try authManager.getAuthId()
            chat = try await chatManager
                .getChat(userId: userId, avatarId: avatarId)
            print("Successfully loading chat: \(String(describing: chat))")
        } catch {
            print("Error loading chat: \(error)")
        }
    }
    
    func listenToChatMessages() async {
        do {
            let chatId = try getChatId()
            print("Listening to chat messages for chatId: \(chatId)")
            
            for try await value in chatManager
                .streamChatMessages(chatId: chatId, onListenerConfigured: { listener in
                    messageListener?.remove()
                    messageListener = listener
                }) {
                chatMessages = value
                    .sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            print("Failed to attach chat message listener: \(error)")
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
}

// MARK: - SectionViews
private extension ChatView {
    var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages + (typingIndicatorMessage.map { [$0] } ?? [])) { message in
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
                    .id(message.id)
                    .transition(.opacity)
                }
                //                ForEach(chatMessages) { message in
                //                    let isCurrentUser = message.authorId == authManager.auth?.uid
                //                    ChatBubbleViewBuilder(
                //                        message: message,
                //                        isCurrentUser: isCurrentUser,
                //                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                //                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                //                        onImageTapped: {
                //                            onAvatarImageTapped()
                //                        }
                //                    )
                //                    .id(message.id)
                //                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        //        .animation(.default, value: chatMessages.count)
        //        .animation(.default, value: scrollPosition)
        .animation(.easeInOut, value: chatMessages.count)
        .animation(.easeInOut, value: scrollPosition)
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
    
    func onSendMessageTapped() {
        guard !textFieldText.isEmpty else { return }
        
        let content = textFieldText
        
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
//                chatMessages.append(message)
                
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
                //                scrollPosition = message.id
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
                
                // upload AI chat
                try await chatManager
                    .addChatMessage(
                        message: newAIMessage
                    )
//                chatMessages.append(newAIMessage)
                isGeneratingResponse = false
                
            } catch let error {
                showAlert = AnyAppAlert(error: error)
            }
            
            isGeneratingResponse = false
        }
    }
    
    func onChatSettingsTapped() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?"
        ) {
            AnyView(
                Group {
                    Button("Report User / Chat", role: .destructive) {
                        
                    }
                    
                    Button("Delete Chat", role: .destructive) {
                        onDeleteChatTapped()
                    }
                }
            )
        }
    }
    
    func onDeleteChatTapped() {
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                
                dismiss()
            } catch {
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please try again later."
                )
            }
        }
    }
    
    func onAvatarImageTapped() {
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
