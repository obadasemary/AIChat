//
//  MessageRowView.swift
//  AIChat
//
//  A complete message row with avatar, bubble, and metadata
//  for iMessage/WhatsApp-style chat interface.
//

import SwiftUI

struct MessageRowView: View {
    
    let message: ChatMessageModel
    let isCurrentUser: Bool
    let avatarImageUrl: String?
    let currentUserProfileColor: Color
    let showAvatar: Bool
    let showTail: Bool
    let onAvatarTapped: (() -> Void)?
    let onReactionTapped: ((MessageReaction) -> Void)?
    let onCopyTapped: (() -> Void)?
    let onShareTapped: (() -> Void)?
    
    init(
        message: ChatMessageModel,
        isCurrentUser: Bool,
        avatarImageUrl: String? = nil,
        currentUserProfileColor: Color = .blue,
        showAvatar: Bool = true,
        showTail: Bool = true,
        onAvatarTapped: (() -> Void)? = nil,
        onReactionTapped: ((MessageReaction) -> Void)? = nil,
        onCopyTapped: (() -> Void)? = nil,
        onShareTapped: (() -> Void)? = nil
    ) {
        self.message = message
        self.isCurrentUser = isCurrentUser
        self.avatarImageUrl = avatarImageUrl
        self.currentUserProfileColor = currentUserProfileColor
        self.showAvatar = showAvatar
        self.showTail = showTail
        self.onAvatarTapped = onAvatarTapped
        self.onReactionTapped = onReactionTapped
        self.onCopyTapped = onCopyTapped
        self.onShareTapped = onShareTapped
    }
    
    private var backgroundColor: Color {
        isCurrentUser ? currentUserProfileColor : Color(uiColor: .systemGray5)
    }
    
    private var textColor: Color {
        isCurrentUser ? .white : .primary
    }
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 8) {
                if !isCurrentUser {
                    avatarView
                } else {
                    Spacer(minLength: 50)
                }
                
                messageContent
                
                if isCurrentUser {
                    // No avatar for current user, but maintain spacing
                } else {
                    Spacer(minLength: 50)
                }
            }
            
            // Reactions display
            if let reactions = message.reactions, !reactions.isEmpty {
                MessageReactionView(
                    reactions: reactions,
                    isCurrentUser: isCurrentUser
                )
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private var avatarView: some View {
        if showAvatar {
            Button {
                onAvatarTapped?()
            } label: {
                if let avatarImageUrl {
                    ImageLoaderView(urlString: avatarImageUrl)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                }
            }
            .buttonStyle(.plain)
        } else {
            // Invisible spacer to maintain alignment
            Color.clear
                .frame(width: 32, height: 32)
        }
    }
    
    private var messageContent: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
            bubbleView
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }

    private var bubbleView: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text(message.content?.message ?? "")
                .font(.body)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.leading)
            
            // Timestamp and read receipt
            HStack(spacing: 2) {
                Text(message.dateCreatedCalculated.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(textColor.opacity(0.7))
                
                if isCurrentUser {
                    readReceiptIcon
                }
            }
        }
        .padding(bubbleContentInsets)
        .background(
            Group {
                if showTail {
                    BubbleShape(isCurrentUser: isCurrentUser)
                        .fill(backgroundColor)
                } else {
                    RoundedRectangle(cornerRadius: BubbleShape.cornerRadius)
                        .fill(backgroundColor)
                }
            }
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: BubbleShape.cornerRadius))
        .contextMenu {
            contextMenuContent
        }
    }

    private var bubbleContentInsets: EdgeInsets {
        let baseHorizontal: CGFloat = 12
        let baseVertical: CGFloat = 12
        let tailInset: CGFloat = showTail ? BubbleShape.tailWidth : 0

        if isCurrentUser {
            return EdgeInsets(
                top: baseVertical,
                leading: baseHorizontal,
                bottom: baseVertical,
                trailing: baseHorizontal + tailInset
            )
        }

        return EdgeInsets(
            top: baseVertical,
            leading: baseHorizontal + tailInset,
            bottom: baseVertical,
            trailing: baseHorizontal
        )
    }
    
    @ViewBuilder
    private var readReceiptIcon: some View {
        let isSeen = message.seenByIds?.isEmpty == false
        Image(systemName: isSeen ? "checkmark.circle.fill" : "checkmark.circle")
            .font(.caption2)
            .foregroundStyle(textColor.opacity(isSeen ? 0.8 : 0.5))
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        // Reactions section
        Section {
            Menu {
                ForEach(MessageReaction.allCases, id: \.self) { reaction in
                    Button {
                        onReactionTapped?(reaction)
                        triggerHaptic(.light)
                    } label: {
                        Label(reaction.emoji, systemImage: "hand.thumbsup")
                    }
                }
            } label: {
                Label("React", systemImage: "face.smiling")
            }
        }
        
        // Quick reactions
        Section {
            Button {
                onReactionTapped?(.like)
                triggerHaptic(.light)
            } label: {
                Label("Like", systemImage: "hand.thumbsup.fill")
            }
            
            Button {
                onReactionTapped?(.love)
                triggerHaptic(.light)
            } label: {
                Label("Love", systemImage: "heart.fill")
            }
        }
        
        // Actions section
        Section {
            Button {
                onCopyTapped?()
                triggerHaptic(.light)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            Button {
                onShareTapped?()
                triggerHaptic(.light)
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview("Message Row") {
    ScrollView {
        VStack(spacing: 4) {
            MessageRowView(
                message: ChatMessageModel(
                    id: "1",
                    chatId: "chat1",
                    authorId: "other",
                    content: AIChatModel(role: .assistant, message: "Hey! How are you?"),
                    seenByIds: ["user1"],
                    dateCreated: .now
                ),
                isCurrentUser: false,
                avatarImageUrl: Constants.randomImage
            )
            
            MessageRowView(
                message: ChatMessageModel(
                    id: "2",
                    chatId: "chat1",
                    authorId: "user1",
                    content: AIChatModel(role: .user, message: "I'm doing great! Working on a new project."),
                    seenByIds: ["user1", "other"],
                    dateCreated: .now
                ),
                isCurrentUser: true,
                currentUserProfileColor: .blue
            )
            
            MessageRowView(
                message: ChatMessageModel(
                    id: "3",
                    chatId: "chat1",
                    authorId: "other",
                    content: AIChatModel(role: .assistant, message: "That sounds exciting! Tell me more about it. I'd love to hear what you're building."),
                    seenByIds: nil,
                    dateCreated: .now
                ),
                isCurrentUser: false,
                avatarImageUrl: Constants.randomImage,
                showAvatar: false,
                showTail: false
            )
            
            MessageRowView(
                message: ChatMessageModel(
                    id: "4",
                    chatId: "chat1",
                    authorId: "user1",
                    content: AIChatModel(role: .user, message: "Sure! It's a chat app with a modern UI like iMessage."),
                    seenByIds: nil,
                    dateCreated: .now
                ),
                isCurrentUser: true,
                currentUserProfileColor: .blue,
                showTail: false
            )
        }
        .padding(.vertical)
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
