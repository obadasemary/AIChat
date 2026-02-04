//
//  ReplyPreviewView.swift
//  AIChat
//
//  Shows a preview of the message being replied to
//

import SwiftUI

struct ReplyPreviewView: View {

    let replyToMessage: String
    let replyToAuthor: String
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(isCurrentUser ? Color.white.opacity(0.5) : Color.accentColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(replyToAuthor)
                    .font(.caption.bold())
                    .foregroundStyle(isCurrentUser ? .white.opacity(0.9) : .primary)

                Text(replyToMessage)
                    .font(.caption)
                    .foregroundStyle(isCurrentUser ? .white.opacity(0.7) : .secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrentUser ? Color.white.opacity(0.15) : Color(uiColor: .systemGray6))
        )
    }
}

// MARK: - Preview
#Preview("Reply Preview") {
    VStack(spacing: 16) {
        ReplyPreviewView(
            replyToMessage: "Hey! How are you doing today?",
            replyToAuthor: "John Doe",
            isCurrentUser: false
        )
        .padding()

        ReplyPreviewView(
            replyToMessage: "I'm doing great! Working on a new project.",
            replyToAuthor: "You",
            isCurrentUser: true
        )
        .padding()
        .background(Color.blue)
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
