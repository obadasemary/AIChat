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
            currentUserId: viewModel.currentUser?.id
        )
        let showTail = messages.shouldShowTail(for: message)

        return MessageRowView(
            message: message,
            isCurrentUser: isCurrentUser,
            avatarImageUrl: isCurrentUser ? nil : viewModel.avatar?.profileImageName,
            currentUserProfileColor: viewModel.currentUser?.profileColorCalculated ?? .blue,
            showAvatar: showAvatar && !isCurrentUser,
            showTail: showTail,
            onAvatarTapped: {
                triggerHaptic(.light)
                viewModel.onAvatarImageTapped()
            }
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
