//
//  MessageKitChatView.swift
//  AIChat
//
//  Created by Claude on 03.02.2026.
//

import SwiftUI
import MessageKit

struct MessageKitChatView: UIViewControllerRepresentable {

    // MARK: - Properties
    let messages: [ChatMessageModel]
    let currentUserId: String
    let currentUserName: String
    let avatarName: String
    let avatarImageName: String?
    let avatarProfileColor: Color
    let onSendMessage: (String) -> Void
    let onAvatarTapped: () -> Void

    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> MessageKitChatViewController {
        let sender = MessageKitSender(
            senderId: currentUserId,
            displayName: currentUserName
        )

        let viewController = MessageKitChatViewController(
            currentSender: sender,
            avatarImageName: avatarImageName,
            avatarProfileColor: UIColor(avatarProfileColor),
            onSendMessage: onSendMessage,
            onAvatarTapped: onAvatarTapped
        )

        return viewController
    }

    func updateUIViewController(_ uiViewController: MessageKitChatViewController, context: Context) {
        let messageKitMessages = messages.map { message in
            message.toMessageKitMessage(currentUserId: currentUserId, avatarName: avatarName)
        }
        uiViewController.updateMessages(messageKitMessages)
    }
}

// MARK: - View Extension
extension MessageKitChatView {
    /// Wraps the view with proper safe area handling
    func withKeyboardHandling() -> some View {
        self
            .ignoresSafeArea(.container, edges: .bottom)
    }
}
