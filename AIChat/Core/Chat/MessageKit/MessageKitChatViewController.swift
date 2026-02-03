//
//  MessageKitChatViewController.swift
//  AIChat
//
//  Created by Claude on 03.02.2026.
//

import UIKit
import MessageKit
import InputBarAccessoryView

@MainActor
final class MessageKitChatViewController: MessagesViewController {

    // MARK: - Properties
    private var messages: [MessageKitMessage] = []
    private let sender: MessageKitSender
    private let avatarImageName: String?
    private let avatarProfileColor: UIColor
    private var onSendMessage: ((String) -> Void)?
    private var onAvatarTapped: (() -> Void)?

    // MARK: - Initialization
    init(
        currentSender: MessageKitSender,
        avatarImageName: String?,
        avatarProfileColor: UIColor,
        onSendMessage: @escaping (String) -> Void,
        onAvatarTapped: @escaping () -> Void
    ) {
        self.sender = currentSender
        self.avatarImageName = avatarImageName
        self.avatarProfileColor = avatarProfileColor
        self.onSendMessage = onSendMessage
        self.onAvatarTapped = onAvatarTapped
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
        disableMessageKitKeyboardManager()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Make input text view first responder to show keyboard
        // This triggers MessageKit's keyboard handling
        DispatchQueue.main.async { [weak self] in
            self?.messageInputBar.inputTextView.becomeFirstResponder()
        }
    }

    private func disableMessageKitKeyboardManager() {
        // SwiftUI already adjusts the hosting view for the keyboard.
        // Disable MessageKit's keyboard manager to avoid double-shifting.
        NotificationCenter.default.removeObserver(keyboardManager)
    }

    // MARK: - Configuration
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        // Styling
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = CGSize(width: 36, height: 36)
        }

        // Background and content insets
        messagesCollectionView.backgroundColor = UIColor.systemBackground
        messagesCollectionView.contentInset.top = 8
        messagesCollectionView.verticalScrollIndicatorInsets.top = 8

        // Keyboard handling
        messagesCollectionView.keyboardDismissMode = .interactive

        // Automatic adjustment for safe areas and tab bar
        messagesCollectionView.contentInsetAdjustmentBehavior = .automatic

        // No additional bottom inset - inputAccessoryView handles it
        additionalBottomInset = 8

        // Don't maintain position when input bar height changes
        maintainPositionOnInputBarHeightChanged = false

        // Scroll to bottom when keyboard appears
        scrollsToLastItemOnKeyboardBeginsEditing = true
    }

    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholder = "Type your message..."
        messageInputBar.sendButton.setTitleColor(UIColor.systemBlue, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor.systemGray, for: .disabled)

        // Configure styling
        messageInputBar.backgroundView.backgroundColor = UIColor.secondarySystemBackground
        messageInputBar.inputTextView.backgroundColor = UIColor.systemBackground
        messageInputBar.inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1
        messageInputBar.inputTextView.layer.cornerRadius = 4
        messageInputBar.inputTextView.placeholderTextColor = UIColor.systemGray
    }

    // MARK: - Public Methods
    func updateMessages(_ messages: [MessageKitMessage]) {
        self.messages = messages
        messagesCollectionView.reloadData()
        scrollToBottom(animated: true)
    }

    func scrollToBottom(animated: Bool = true) {
        guard !messages.isEmpty else { return }
        messagesCollectionView.scrollToLastItem(animated: animated)
    }
}

// MARK: - MessagesDataSource
extension MessageKitChatViewController: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        sender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
}

// MARK: - MessagesLayoutDelegate
extension MessageKitChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        // Only show avatar for received messages
        if message.sender.senderId == sender.senderId {
            return .zero
        }
        return CGSize(width: 36, height: 36)
    }
}

// MARK: - MessagesDisplayDelegate
extension MessageKitChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == sender.senderId {
            return UIColor.systemBlue
        }
        return UIColor.systemGray5
    }

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == sender.senderId {
            return .white
        }
        return .label
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Only configure avatar for received messages
        guard message.sender.senderId != sender.senderId else {
            avatarView.isHidden = true
            return
        }

        avatarView.isHidden = false

        // Load avatar image if available
        if let imageName = avatarImageName, let image = UIImage(named: imageName) {
            avatarView.image = image
        } else {
            // Use initials with background color
            let initials = String(message.sender.displayName.prefix(2))
            avatarView.set(avatar: Avatar(image: nil, initials: initials))
            avatarView.backgroundColor = avatarProfileColor
        }
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = message.sender.senderId == sender.senderId ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessageCellDelegate
extension MessageKitChatViewController: @preconcurrency MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        onAvatarTapped?()
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension MessageKitChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // Clear input
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()

        // Send message
        onSendMessage?(trimmedText)
    }
}
