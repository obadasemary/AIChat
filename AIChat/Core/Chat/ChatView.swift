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
// swiftlint:disable blanket_disable_command
// swiftlint:disable file_length
struct ChatView: View {

    @State var presenter: ChatPresenter
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
            await presenter.loadAvatar(avatarId: delegate.avatarId)
        }
        .task {
            await presenter.loadChat(avatarId: delegate.avatarId)
            await presenter.listenToChatMessages()
        }
        .onFirstAppear {
            presenter.onViewFirstAppear(chat: delegate.chat)
        }
        .onDisappear {
            presenter.onDisappear()
        }
    }
}

// MARK: - Navigation Bar Components
private extension ChatView {

    var navigationTitleView: some View {
        ChatNavigationTitleView(
            name: presenter.avatar?.name ?? "Chat",
            avatarImageUrl: presenter.avatar?.profileImageName,
            isOnline: true,
            isTyping: presenter.isGeneratingResponse,
            onTapped: {
                presenter.onAvatarImageTapped()
            }
        )
    }

    @ViewBuilder
    var settingsButton: some View {
        if presenter.isGeneratingResponse {
            ProgressView()
                .controlSize(.small)
        } else {
            Menu {
                Button(role: .destructive) {
                    presenter.onReportChatTapped()
                } label: {
                    Label("Report Chat", systemImage: "exclamationmark.triangle")
                }

                Button(role: .destructive) {
                    presenter.onDeleteChatTapped()
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
                    if presenter.typingIndicatorMessage != nil {
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
            .onChange(of: presenter.scrollPosition) { _, newValue in
                if let newValue {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(newValue, anchor: .bottom)
                    }
                }
            }
            .onChange(of: presenter.typingIndicatorMessage) { _, newValue in
                if newValue != nil {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    var messageGroups: [MessageGroup] {
        presenter.chatMessages.groupedByDate()
    }

    func dateHeader(for date: Date) -> some View {
        DateHeaderView(date: date)
            .padding(.top, 8)
    }

    // swiftlint:disable function_body_length
    func messageRow(
        for message: ChatMessageModel,
        in messages: [ChatMessageModel]
    ) -> some View {
        let isCurrentUser = presenter.messageIsCurrentUser(message: message)
        let showAvatar = messages.shouldShowAvatar(
            for: message,
            currentUserId: presenter.currentUser?.userId
        )
        let showTail = false
        let replyToMessage = message.replyToMessageId.flatMap { replyId in
            presenter.chatMessages.first { $0.id == replyId }
        }

        return MessageRowView(
            message: message,
            isCurrentUser: isCurrentUser,
            currentUserId: presenter.currentUser?.userId,
            avatarImageUrl: isCurrentUser ? nil : presenter.avatar?.profileImageName,
            currentUserProfileColor: presenter.currentUser?.profileColorCalculated ?? .blue,
            showAvatar: showAvatar && !isCurrentUser,
            showTail: showTail,
            replyToMessage: replyToMessage,
            onAvatarTapped: {
                triggerHaptic(.light)
                presenter.onAvatarImageTapped()
            },
            onLongPress: {
                triggerHaptic(.medium)
                selectedMessageForReaction = message
            },
            onReactionTapped: { reaction in
                presenter.onMessageReactionTapped(message: message, reaction: reaction)
            },
            onCopyTapped: {
                presenter.onMessageCopyTapped(message: message)
            },
            onShareTapped: {
                presenter.onMessageShareTapped(message: message)
            },
            onReplyTapped: {
                triggerHaptic(.light)
                presenter.onMessageReplyTapped(message: message)
            },
            onEditTapped: {
                triggerHaptic(.light)
                presenter.onMessageEditTapped(message: message)
            },
            onTranslateTapped: {
                triggerHaptic(.light)
                presenter.onMessageTranslateTapped(message: message)
            },
            onSelectTapped: {
                triggerHaptic(.light)
                presenter.onMessageSelectTapped(message: message)
            },
            translatedText: presenter.translatedMessages[message.id]
        )
        .onAppear {
            presenter.onMessageDidAppear(message: message)
        }
        .padding(.vertical, showTail ? 4 : 1)
    }
    // swiftlint:enable function_body_length

    var typingIndicator: some View {
        TypingIndicatorView(
            avatarImageUrl: presenter.avatar?.profileImageName,
            showAvatar: true
        )
        .padding(.vertical, 4)
    }

    // swiftlint:disable superfluous_disable_command
    // swiftlint:disable function_body_length
    func reactionOverlay(for message: ChatMessageModel) -> some View {
        let isCurrentUser = presenter.messageIsCurrentUser(message: message)
        let backgroundColor = isCurrentUser ? (presenter.currentUser?.profileColorCalculated ?? .blue) : Color(uiColor: .systemGray5)
        let textColor = isCurrentUser ? Color.white : Color.primary
        let replyToMessage = message.replyToMessageId.flatMap { replyId in
            presenter.chatMessages.first { $0.id == replyId }
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
                        presenter.onMessageReactionTapped(message: message, reaction: reaction)
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
    // swiftlint:enable function_body_length
    // swiftlint:enable superfluous_disable_command

    // swiftlint:disable superfluous_disable_command
    // swiftlint:disable function_body_length
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
                    if let translatedText = presenter.translatedMessages[message.id] {
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
    // swiftlint:enable function_body_length
    // swiftlint:enable superfluous_disable_command

    func messageActionsView(for message: ChatMessageModel, isCurrentUser: Bool) -> some View {
        VStack(spacing: 0) {
            actionButton(icon: "arrowshape.turn.up.left", label: "Reply") {
                presenter.onMessageReplyTapped(message: message)
                withAnimation {
                    selectedMessageForReaction = nil
                }
            }

            if isCurrentUser && message.canEdit {
                Divider()
                    .padding(.leading, 44)

                actionButton(icon: "pencil", label: "Edit") {
                    presenter.onMessageEditTapped(message: message)
                    withAnimation {
                        selectedMessageForReaction = nil
                    }
                }
            }

            Divider()
                .padding(.leading, 44)

            actionButton(icon: "doc.on.doc", label: "Copy") {
                presenter.onMessageCopyTapped(message: message)
                withAnimation {
                    selectedMessageForReaction = nil
                }
            }

            Divider()
                .padding(.leading, 44)

            actionButton(icon: "character.bubble", label: "Translate") {
                presenter.onMessageTranslateTapped(message: message)
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
            text: $presenter.textFieldText,
            isFocused: $isTextFieldFocused,
            isLoading: presenter.isGeneratingResponse,
            placeholder: "Type your message...",
            accentColor: presenter.currentUser?.profileColorCalculated ?? .blue,
            onSendTapped: {
                triggerHaptic(.medium)
                presenter.onSendMessageTapped(avatarId: delegate.avatarId)
            },
            replyingToMessage: presenter.replyingToMessage,
            editingMessage: presenter.editingMessage,
            onCancelReply: {
                presenter.cancelReply()
            },
            onCancelEdit: {
                presenter.cancelEdit()
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
// swiftlint:enable file_length
// swiftlint:enable blanket_disable_command
