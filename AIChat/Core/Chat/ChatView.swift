//
//  ChatView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.06.2025.
//
//  A modern chat view with iMessage/WhatsApp-style UI featuring:
//  - Bubble tails and smooth corners
//  - Date headers for message grouping
//  - Animated typing indicator
//  - Read receipts
//  - Modern input bar
//  - Haptic feedback
//

import SwiftUI

struct ChatView: View {

    @State var viewModel: ChatViewModel
    @FocusState private var isTextFieldFocused: Bool

    let delegate: ChatDelegate

    // Animation states
    @State private var showScrollToBottom: Bool = false
    @Namespace private var bottomID

    // Reaction overlay state
    @State private var selectedMessageForReaction: ChatMessageModel?

    var body: some View {
        VStack(spacing: 0) {
            messagesScrollView
            inputBarSection
        }
        .background(chatBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                navigationTitleView
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                settingsButton
            }
        }
        .overlay {
            if let selectedMessage = selectedMessageForReaction {
                reactionOverlay(for: selectedMessage)
            }
        }
        .screenAppearAnalytics(name: ScreenName.from(Self.self))
        .task {
            await viewModel.loadAvatar(avatarId: delegate.avatarId)
        }
        .task {
            await viewModel.loadChat(avatarId: delegate.avatarId)
            await viewModel.listenToChatMessages()
        }
        .onFirstAppear {
            viewModel.onViewFirstAppear(chat: delegate.chat)
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

// MARK: - Navigation Bar Components
private extension ChatView {

    var navigationTitleView: some View {
        ChatNavigationTitleView(
            name: viewModel.avatar?.name ?? "Chat",
            avatarImageUrl: viewModel.avatar?.profileImageName,
            isOnline: true,
            isTyping: viewModel.isGeneratingResponse,
            onTapped: {
                viewModel.onAvatarImageTapped()
            }
        )
    }

    @ViewBuilder
    var settingsButton: some View {
        if viewModel.isGeneratingResponse {
            ProgressView()
                .controlSize(.small)
        } else {
            Menu {
                Button(role: .destructive) {
                    viewModel.onReportChatTapped()
                } label: {
                    Label("Report Chat", systemImage: "exclamationmark.triangle")
                }

                Button(role: .destructive) {
                    viewModel.onDeleteChatTapped()
                } label: {
                    Label("Delete Chat", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Messages Section
private extension ChatView {

    var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    // Group messages by date
                    ForEach(messageGroups) { group in
                        dateHeader(for: group.date)

                        ForEach(group.messages) { message in
                            messageRow(for: message, in: group.messages)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                        }
                    }

                    // Typing indicator
                    if viewModel.typingIndicatorMessage != nil {
                        typingIndicator
                            .id("typing")
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // Bottom anchor for scrolling
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.scrollPosition) { _, newValue in
                if let newValue {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(newValue, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.typingIndicatorMessage) { _, newValue in
                if newValue != nil {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    var messageGroups: [MessageGroup] {
        viewModel.chatMessages.groupedByDate()
    }

    func dateHeader(for date: Date) -> some View {
        DateHeaderView(date: date)
            .padding(.top, 8)
    }

    func messageRow(for message: ChatMessageModel, in messages: [ChatMessageModel]) -> some View {
        let isCurrentUser = viewModel.messageIsCurrentUser(message: message)
        let showAvatar = messages.shouldShowAvatar(
            for: message,
            currentUserId: viewModel.currentUser?.userId
        )
        let showTail = false
        let replyToMessage = message.replyToMessageId.flatMap { replyId in
            viewModel.chatMessages.first { $0.id == replyId }
        }

        return MessageRowView(
            message: message,
            isCurrentUser: isCurrentUser,
            avatarImageUrl: isCurrentUser ? nil : viewModel.avatar?.profileImageName,
            currentUserProfileColor: viewModel.currentUser?.profileColorCalculated ?? .blue,
            showAvatar: showAvatar && !isCurrentUser,
            showTail: showTail,
            replyToMessage: replyToMessage,
            onAvatarTapped: {
                triggerHaptic(.light)
                viewModel.onAvatarImageTapped()
            },
            onLongPress: {
                triggerHaptic(.medium)
                selectedMessageForReaction = message
            },
            onReactionTapped: { reaction in
                viewModel.onMessageReactionTapped(message: message, reaction: reaction)
            },
            onCopyTapped: {
                viewModel.onMessageCopyTapped(message: message)
            },
            onShareTapped: {
                viewModel.onMessageShareTapped(message: message)
            },
            onReplyTapped: {
                triggerHaptic(.light)
                viewModel.onMessageReplyTapped(message: message)
            },
            onEditTapped: {
                triggerHaptic(.light)
                viewModel.onMessageEditTapped(message: message)
            },
            onTranslateTapped: {
                triggerHaptic(.light)
                viewModel.onMessageTranslateTapped(message: message)
            },
            onSelectTapped: {
                triggerHaptic(.light)
                viewModel.onMessageSelectTapped(message: message)
            },
            translatedText: viewModel.translatedMessages[message.id]
        )
        .onAppear {
            viewModel.onMessageDidAppear(message: message)
        }
        .padding(.vertical, showTail ? 4 : 1)
    }

    var typingIndicator: some View {
        TypingIndicatorView(
            avatarImageUrl: viewModel.avatar?.profileImageName,
            showAvatar: true
        )
        .padding(.vertical, 4)
    }

    func reactionOverlay(for message: ChatMessageModel) -> some View {
        let isCurrentUser = viewModel.messageIsCurrentUser(message: message)
        let backgroundColor = isCurrentUser ? (viewModel.currentUser?.profileColorCalculated ?? .blue) : Color(uiColor: .systemGray5)
        let textColor = isCurrentUser ? Color.white : Color.primary
        let replyToMessage = message.replyToMessageId.flatMap { replyId in
            viewModel.chatMessages.first { $0.id == replyId }
        }

        return Color.black.opacity(0.001)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation {
                    selectedMessageForReaction = nil
                }
            }
            .overlay(alignment: .center) {
                VStack(alignment: .center, spacing: 10) {
                    // Reactions at top
                    ReactionPickerView { reaction in
                        viewModel.onMessageReactionTapped(message: message, reaction: reaction)
                        withAnimation {
                            selectedMessageForReaction = nil
                        }
                    }

                    // Message preview in middle (full width)
                    messageBubblePreview(for: message, isCurrentUser: isCurrentUser, backgroundColor: backgroundColor, textColor: textColor, replyToMessage: replyToMessage)
                        .frame(maxWidth: .infinity)

                    // Actions at bottom (full width)
                    messageActionsView(for: message, isCurrentUser: isCurrentUser)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 60)
                .transition(.scale.combined(with: .opacity))
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMessageForReaction != nil)
    }

    func messageBubblePreview(for message: ChatMessageModel, isCurrentUser: Bool, backgroundColor: Color, textColor: Color, replyToMessage: ChatMessageModel?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Reply preview if exists
            if let replyToMessage {
                ReplyPreviewView(
                    replyToMessage: replyToMessage.content?.message ?? "",
                    replyToAuthor: isCurrentUser ? "You" : "AI Assistant",
                    isCurrentUser: isCurrentUser
                )
            }

            // Message content
            HStack(alignment: .bottom, spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    if let translatedText = viewModel.translatedMessages[message.id] {
                        Text(translatedText)
                            .font(.body)
                            .foregroundStyle(textColor)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 4) {
                            Image(systemName: "character.bubble")
                                .font(.caption2)
                            Text("Translated")
                                .font(.caption2)
                        }
                        .foregroundStyle(textColor.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(textColor.opacity(0.1))
                        )
                    } else {
                        Text(message.content?.message ?? "")
                            .font(.body)
                            .foregroundStyle(textColor)
                            .multilineTextAlignment(.leading)
                    }

                    if message.isEdited {
                        Text("Edited")
                            .font(.caption2)
                            .foregroundStyle(textColor.opacity(0.5))
                            .italic()
                    }
                }

                // Timestamp
                Text(message.dateCreatedCalculated.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(textColor.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }

    func messageActionsView(for message: ChatMessageModel, isCurrentUser: Bool) -> some View {
        VStack(spacing: 0) {
            actionButton(icon: "arrowshape.turn.up.left", label: "Reply") {
                viewModel.onMessageReplyTapped(message: message)
                withAnimation {
                    selectedMessageForReaction = nil
                }
            }

            if isCurrentUser && message.canEdit {
                Divider()
                    .padding(.leading, 44)

                actionButton(icon: "pencil", label: "Edit") {
                    viewModel.onMessageEditTapped(message: message)
                    withAnimation {
                        selectedMessageForReaction = nil
                    }
                }
            }

            Divider()
                .padding(.leading, 44)

            actionButton(icon: "doc.on.doc", label: "Copy") {
                viewModel.onMessageCopyTapped(message: message)
                withAnimation {
                    selectedMessageForReaction = nil
                }
            }

            Divider()
                .padding(.leading, 44)

            actionButton(icon: "character.bubble", label: "Translate") {
                viewModel.onMessageTranslateTapped(message: message)
                withAnimation {
                    selectedMessageForReaction = nil
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        )
    }

    func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            triggerHaptic(.light)
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
                    .frame(width: 28)

                Text(label)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Input Bar Section
private extension ChatView {

    var inputBarSection: some View {
        SimpleChatInputBar(
            text: $viewModel.textFieldText,
            isFocused: $isTextFieldFocused,
            isLoading: viewModel.isGeneratingResponse,
            placeholder: "Type your message...",
            accentColor: viewModel.currentUser?.profileColorCalculated ?? .blue,
            onSendTapped: {
                triggerHaptic(.medium)
                viewModel.onSendMessageTapped(avatarId: delegate.avatarId)
            },
            replyingToMessage: viewModel.replyingToMessage,
            editingMessage: viewModel.editingMessage,
            onCancelReply: {
                viewModel.cancelReply()
            },
            onCancelEdit: {
                viewModel.cancelEdit()
            }
        )
    }
}

// MARK: - Background
private extension ChatView {

    var chatBackground: some View {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
    }
}

// MARK: - Haptic Feedback
private extension ChatView {

    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview Working Chat Not Premium
#Preview("Working Chat - Not Premium") {
    let container = DevPreview.shared.container
    let chatBuilder = ChatBuilder(container: container)
    let delegate = ChatDelegate(avatarId: AvatarModel.mock.avatarId)
    
    return RouterView { router in
        chatBuilder.buildChatView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

// MARK: - Preview Working Chat Premium
#Preview("Working Chat - Premium") {
    let container = DevPreview.shared.container
    
    container.register(PurchaseManager.self) {
        PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock]))
    }
    
    let chatBuilder = ChatBuilder(container: container)
    let delegate = ChatDelegate(avatarId: AvatarModel.mock.avatarId)
    
    return RouterView { router in
        chatBuilder.buildChatView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

// MARK: - Preview Slow AI Generation
#Preview("Slow AI Generation") {
    let container = DevPreview.shared.container
    
    container.register(AIManager.self) {
        AIManager(service: MockAIServer(delay: 10))
    }
    
    let chatBuilder = ChatBuilder(container: container)
    let delegate = ChatDelegate(avatarId: AvatarModel.mock.avatarId)
    
    return RouterView { router in
        chatBuilder.buildChatView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

// MARK: - Preview Failed AI Generation
#Preview("Failed AI Generation") {
    let container = DevPreview.shared.container
    
    container.register(PurchaseManager.self) {
        PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock]))
    }
    
    container.register(AIManager.self) {
        AIManager(service: MockAIServer(delay: 2, showError: true))
    }
    
    let chatBuilder = ChatBuilder(container: container)
    let delegate = ChatDelegate(avatarId: AvatarModel.mock.avatarId)
    
    return RouterView { router in
        chatBuilder.buildChatView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
