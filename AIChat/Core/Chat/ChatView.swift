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
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State private var chat: ChatModel?
    
    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?
    
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    @State private var isGeneratingResponse: Bool = false
    @State private var typingIndicatorMessage: ChatMessageModel?
    
    var avatarId: String
    
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
        .onAppear {
            loadCurrentUser()
        }
    }
    
    
}

// MARK: - load
private extension ChatView {
    private func loadAvatar() async {
        do {
            avatar = try await avatarManager.getAvatar(id: avatarId)
            guard let avatar else { return }
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            print("Error loading avatar: \(error)")
        }
    }
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    
    
    private func profileModal(avatar: AvatarModel) -> some View {
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
    private var scrollViewSection: some View {
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
    
    private var textFieldSection: some View {
        TextField("Type your message...", text: $textFieldText, axis: .vertical)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
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
    
    private func onSendMessageTapped() {
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
                chatMessages.append(message)
                
                // clear text field & scroll to bottom
                
                // Show fake typing message
                let typingMessage = ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: chat.id,
                    authorId: avatarId,
                    content: AIChatModel(role: .assistant, message: "✍️..."),
                    seenByIds: [],
                    dateCreated: .now
                )
                typingIndicatorMessage = typingMessage
                //                scrollPosition = message.id
                scrollPosition = typingMessage.id
                textFieldText = ""
                
                // Generate AI response
                isGeneratingResponse = true
                let aiChats = chatMessages.compactMap({ $0.content })
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
                chatMessages.append(newAIMessage)
                isGeneratingResponse = false
                
            } catch let error {
                showAlert = AnyAppAlert(error: error)
            }
            
            isGeneratingResponse = false
        }
    }
    
    private func onChatSettingsTapped() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?"
        ) {
            AnyView(
                Group {
                    Button("Report User / Chat", role: .destructive) {
                        
                    }
                    
                    Button("Delete Chat", role: .destructive) {
                        
                    }
                }
            )
        }
    }
    
    private func onAvatarImageTapped() {
        showProfileModal = true
    }
}

// MARK: - helper func
private extension ChatView {
    enum ChatViewEror: Error {
        case failedToCreateNewChat
    }
    
    private func createNewChat(userId: String) async throws -> ChatModel {
        let newChat = ChatModel.new(
            userId: userId,
            avatarId: avatarId
        )
        try await chatManager.createNewChat(chat: newChat)
        return newChat
    }
}

#Preview("Working Chat") {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .previewEnvironment()
    }
}

#Preview("Slow AI Generation") {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .environment(AIManager(service: MockAIServer(delay: 10)))
            .previewEnvironment()
    }
}

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
