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
                Image(systemName: "ellipsis")
                    .padding(8)
                    .anyButton {
                        onChatSettingsTapped()
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
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
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
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
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
    
    private func onSendMessageTapped() {
        guard !textFieldText.isEmpty else { return }
        
        let content = textFieldText
        
        Task {        
            do {
                let userId = try authManager.getAuthId()
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                if chat == nil {
                    let newChat = ChatModel.new(
                        userId: userId,
                        avatarId: avatarId
                    )
                    try await chatManager.createNewChat(chat: newChat)
                    chat = newChat
                }
                
                let newChatMessage = AIChatModel(role: .user, message: content)
                
                let chatId = UUID().uuidString
                let message = ChatMessageModel.newUserMessage(
                    chatId: chatId,
                    userId: userId,
                    message: newChatMessage
                )
                
                scrollPosition = message.id
                
                chatMessages.append(message)
                textFieldText = ""
                
                let aiChats = chatMessages.compactMap({ $0.content })
                
                let response = try await aiManager.generateText(chats: aiChats)
                
                let newAIMessage = ChatMessageModel.newUAIMessage(
                    chatId: chatId,
                    avatarId: avatarId,
                    message: response
                )
                chatMessages.append(newAIMessage)
                
            } catch let error {
                showAlert = AnyAppAlert(error: error)
            }
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

#Preview {
    NavigationStack {
        ChatView(avatarId: AvatarModel.mock.avatarId)
            .previewEnvironment()
    }
}
