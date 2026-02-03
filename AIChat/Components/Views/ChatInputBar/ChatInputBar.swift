//
//  ChatInputBar.swift
//  AIChat
//
//  A modern chat input bar with WhatsApp/iMessage-like design
//  featuring attachment options, microphone button, and smooth animations.
//

import SwiftUI

struct ChatInputBar: View {

    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    let isLoading: Bool
    let onSendTapped: () -> Void
    let onAttachmentTapped: (() -> Void)?
    let onMicrophoneTapped: (() -> Void)?

    @State private var textEditorHeight: CGFloat = 36

    private let minHeight: CGFloat = 36
    private let maxHeight: CGFloat = 120

    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        isLoading: Bool = false,
        onSendTapped: @escaping () -> Void,
        onAttachmentTapped: (() -> Void)? = nil,
        onMicrophoneTapped: (() -> Void)? = nil
    ) {
        self._text = text
        self._isFocused = isFocused
        self.isLoading = isLoading
        self.onSendTapped = onSendTapped
        self.onAttachmentTapped = onAttachmentTapped
        self.onMicrophoneTapped = onMicrophoneTapped
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 8) {
                // Attachment button
                if let onAttachmentTapped {
                    attachmentButton(action: onAttachmentTapped)
                }

                // Text input area
                textInputArea

                // Send or Microphone button
                actionButton
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemBackground))
        }
    }

    private func attachmentButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    private var textInputArea: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField("Message", text: $text, axis: .vertical)
                .font(.body)
                .lineLimit(1...6)
                .focused($isFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .accessibilityIdentifier("ChatInputTextField")
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(uiColor: .systemGray4), lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private var actionButton: some View {
        if isLoading {
            ProgressView()
                .frame(width: 36, height: 36)
        } else if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Show microphone when no text
            if let onMicrophoneTapped {
                microphoneButton(action: onMicrophoneTapped)
            } else {
                sendButton
                    .opacity(0.4)
                    .disabled(true)
            }
        } else {
            sendButton
        }
    }

    private var sendButton: some View {
        Button(action: onSendTapped) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text.isEmpty)
    }

    private func microphoneButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Simple Chat Input Bar (without attachment/mic)
struct SimpleChatInputBar: View {

    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    let isLoading: Bool
    let placeholder: String
    let accentColor: Color
    let onSendTapped: () -> Void

    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        isLoading: Bool = false,
        placeholder: String = "Message",
        accentColor: Color = .blue,
        onSendTapped: @escaping () -> Void
    ) {
        self._text = text
        self._isFocused = isFocused
        self.isLoading = isLoading
        self.placeholder = placeholder
        self.accentColor = accentColor
        self.onSendTapped = onSendTapped
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 12) {
                // Text field
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(.body)
                    .lineLimit(1...6)
                    .focused($isFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(uiColor: .systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color(uiColor: .systemGray4), lineWidth: 0.5)
                    )
                    .accessibilityIdentifier("ChatTextField")

                // Send button
                sendButton
                    .padding(.trailing, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemBackground))
        }
    }

    @ViewBuilder
    private var sendButton: some View {
        if isLoading {
            ProgressView()
                .frame(width: 36, height: 36)
        } else {
            Button(action: onSendTapped) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(canSend ? accentColor : accentColor.opacity(0.4))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .animation(.easeInOut(duration: 0.2), value: canSend)
        }
    }
}

// MARK: - Preview
#Preview("Chat Input Bar - Full") {
    struct PreviewWrapper: View {
        @State private var text = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack {
                Spacer()

                ChatInputBar(
                    text: $text,
                    isFocused: $isFocused,
                    onSendTapped: { print("Send tapped") },
                    onAttachmentTapped: { print("Attachment tapped") },
                    onMicrophoneTapped: { print("Mic tapped") }
                )
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Chat Input Bar - With Text") {
    struct PreviewWrapper: View {
        @State private var text = "Hello, this is a message!"
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack {
                Spacer()

                ChatInputBar(
                    text: $text,
                    isFocused: $isFocused,
                    onSendTapped: { print("Send tapped") },
                    onAttachmentTapped: { print("Attachment tapped") }
                )
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Chat Input Bar - Loading") {
    struct PreviewWrapper: View {
        @State private var text = "Sending..."
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack {
                Spacer()

                ChatInputBar(
                    text: $text,
                    isFocused: $isFocused,
                    isLoading: true,
                    onSendTapped: { }
                )
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Simple Chat Input Bar") {
    struct PreviewWrapper: View {
        @State private var text = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack {
                Spacer()

                SimpleChatInputBar(
                    text: $text,
                    isFocused: $isFocused,
                    placeholder: "Type your message...",
                    accentColor: .purple,
                    onSendTapped: { print("Send tapped") }
                )
            }
        }
    }

    return PreviewWrapper()
}
