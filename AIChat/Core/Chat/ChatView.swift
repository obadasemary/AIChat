//
//  ChatView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.06.2025.
//

import SwiftUI

struct ChatView: View {
    
    @State var viewModel: ChatViewModel
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var avatarId: String
    var chat: ChatModel?
    
    var body: some View {
        VStack(spacing: .zero) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(viewModel.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if viewModel.isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .anyButton {
                            viewModel.onChatSettingsTapped {
                                dismiss()
                            }
                        }
                    
                }
            }
        }
        .screenAppearAnalytics(name: ScreenName.from(Self.self))
        .showCustomAlert(type: .confirmationDialog, alert: $viewModel.showChatSettings)
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.showProfileModal) {
            if let avatar = viewModel.avatar {
                profileModal(avatar: avatar)
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        .task {
            await viewModel.loadAvatar(avatarId: avatarId)
        }
        .task {
            await viewModel.loadChat(avatarId: avatarId)
            await viewModel.listenToChatMessages()
        }
        .onFirstAppear {
            viewModel.onViewFirstAppear(chat: chat)
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

// MARK: - SectionViews
private extension ChatView {
    var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.chatMessages + (viewModel.typingIndicatorMessage.map { [$0] } ?? [])) { message in
                    
                    if viewModel.messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    
                    let isCurrentUser = (try? viewModel.messageIsCurrentUser(
                        message: message
                    )) ?? false
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: viewModel.currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : viewModel.avatar?.profileImageName,
                        onImageTapped: {
                            viewModel.onAvatarImageTapped()
                        }
                    )
                    .onAppear {
                        viewModel.onMessageDidAppear(message: message)
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
        .scrollPosition(id: $viewModel.scrollPosition, anchor: .center)
        .animation(.easeInOut, value: viewModel.chatMessages.count)
        .animation(.easeInOut, value: viewModel.scrollPosition)
    }
    
    func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription
        ) {
            viewModel.onProfileModalXmarksTapped()
        }
        .padding()
        .transition(.slide)
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
            text: $viewModel.textFieldText,
            axis: .vertical
        )
        .keyboardType(.default)
        .autocorrectionDisabled()
        .focused($isTextFieldFocused)
        .onSubmit {
            isTextFieldFocused = false
            if !viewModel.textFieldText.isEmpty {
                viewModel.onSendMessageTapped(avatarId: avatarId)
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
                    viewModel.onSendMessageTapped(avatarId: avatarId)
                }
                .disabled(viewModel.textFieldText.isEmpty)
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
    NavigationStack {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: DevPreview.shared.container)
            ),
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
}

// MARK: - Preview Working Chat Premium
#Preview("Working Chat - Premium") {
    let container = DevPreview.shared.container
    
    container.register(PurchaseManager.self) {
        PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock]))
    }
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: container)
            ),
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
}

// MARK: - Preview Slow AI Generation
#Preview("Slow AI Generation") {
    let container = DevPreview.shared.container
    
    container.register(AIManager.self) {
        AIManager(service: MockAIServer(delay: 10))
    }
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: container)
            ),
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
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
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: container)
            ),
            avatarId: AvatarModel.mock.avatarId
        )
        .previewEnvironment()
    }
}
