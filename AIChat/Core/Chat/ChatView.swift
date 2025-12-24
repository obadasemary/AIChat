//
//  ChatView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.06.2025.
//

import SwiftUI

struct ChatView: View {
    
    @State var presenter: ChatPresenter
    @FocusState private var isTextFieldFocused: Bool
    
    let delegate: ChatDelegate
    
    var body: some View {
        VStack(spacing: .zero) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(presenter.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if presenter.isGeneratingResponse {
                        ProgressView()
                    } else {
                        Image(systemName: "ellipsis")
                            .padding(8)
                            .anyButton {
                                presenter.onChatSettingsTapped()
                            }
                    }
                }
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

// MARK: - SectionViews
private extension ChatView {
    var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(presenter.chatMessages + (presenter.typingIndicatorMessage.map { [$0] } ?? [])) { message in
                    
                    if presenter.messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }

                    let isCurrentUser = presenter
                        .messageIsCurrentUser(message: message)
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: presenter.currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : presenter.avatar?.profileImageName,
                        onImageTapped: {
                            presenter.onAvatarImageTapped()
                        }
                    )
                    .onAppear {
                        presenter.onMessageDidAppear(message: message)
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
        .scrollPosition(id: $presenter.scrollPosition, anchor: .center)
        .animation(.easeInOut, value: presenter.chatMessages.count)
        .animation(.easeInOut, value: presenter.scrollPosition)
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
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    var textFieldSection: some View {
        TextField(
            "Type your message...",
            text: $presenter.textFieldText,
            axis: .vertical
        )
        .keyboardType(.default)
        .autocorrectionDisabled()
        .focused($isTextFieldFocused)
        .onSubmit {
            isTextFieldFocused = false
            if !presenter.textFieldText.isEmpty {
                presenter.onSendMessageTapped(avatarId: delegate.avatarId)
            }
        }
        .padding(12)
        .padding(.trailing, 60)
        .accessibilityIdentifier("ChatTextField")
        .overlay(alignment: .trailing) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .padding(.trailing, 4)
                .foregroundStyle(.accent)
                .anyButton(.plain) {
                    presenter.onSendMessageTapped(avatarId: delegate.avatarId)
                }
                .disabled(presenter.textFieldText.isEmpty)
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
