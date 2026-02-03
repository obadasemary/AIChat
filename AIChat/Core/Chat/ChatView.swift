//
//  ChatView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.06.2025.
//

import SwiftUI

struct ChatView: View {

    @State var viewModel: ChatViewModel

    let delegate: ChatDelegate

    var body: some View {
        Group {
            if let currentUser = viewModel.currentUser,
               let avatar = viewModel.avatar {
                MessageKitChatView(
                    messages: viewModel.chatMessages,
                    currentUserId: currentUser.userId,
                    currentUserName: currentUser.email ?? "You",
                    avatarName: avatar.name ?? "Avatar",
                    avatarImageName: avatar.profileImageName,
                    avatarProfileColor: currentUser.profileColorCalculated,
                    onSendMessage: { text in
                        viewModel.sendMessage(text: text, avatarId: delegate.avatarId)
                    },
                    onAvatarTapped: {
                        viewModel.onAvatarImageTapped()
                    }
                )
                .withKeyboardHandling()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(viewModel.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if viewModel.isGeneratingResponse {
                        ProgressView()
                    } else {
                        Image(systemName: "ellipsis")
                            .padding(8)
                            .anyButton {
                                viewModel.onChatSettingsTapped()
                            }
                    }
                }
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

// MARK: - Note
// MessageKit integration replaces the custom chat UI
// Old scroll view and text field sections have been replaced with MessageKitChatView

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
