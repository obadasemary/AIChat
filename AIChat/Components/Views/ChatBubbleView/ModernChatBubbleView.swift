//
//  ModernChatBubbleView.swift
//  AIChat
//
//  A modern chat bubble view with iMessage/WhatsApp-like design
//  featuring bubble tails, smooth corners, and elegant styling.
//

import SwiftUI

struct ModernChatBubbleView: View {

    let text: String
    let isCurrentUser: Bool
    let backgroundColor: Color
    let textColor: Color
    let timestamp: Date?
    let isRead: Bool
    let showTail: Bool

    init(
        text: String,
        isCurrentUser: Bool,
        backgroundColor: Color? = nil,
        textColor: Color? = nil,
        timestamp: Date? = nil,
        isRead: Bool = false,
        showTail: Bool = true
    ) {
        self.text = text
        self.isCurrentUser = isCurrentUser
        self.backgroundColor = backgroundColor ?? (isCurrentUser ? .blue : Color(uiColor: .systemGray5))
        self.textColor = textColor ?? (isCurrentUser ? .white : .primary)
        self.timestamp = timestamp
        self.isRead = isRead
        self.showTail = showTail
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            if isCurrentUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                bubbleContent
            }

            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }

    private var bubbleContent: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)

            if let timestamp {
                HStack(spacing: 2) {
                    Text(timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(textColor.opacity(0.7))

                    if isCurrentUser {
                        readReceiptIcon
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(bubbleShape)
    }

    @ViewBuilder
    private var readReceiptIcon: some View {
        if isRead {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
                .foregroundStyle(textColor.opacity(0.7))
        } else {
            Image(systemName: "checkmark.circle")
                .font(.caption2)
                .foregroundStyle(textColor.opacity(0.5))
        }
    }

    @ViewBuilder
    private var bubbleShape: some View {
        if showTail {
            BubbleShape(isCurrentUser: isCurrentUser)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        } else {
            RoundedRectangle(cornerRadius: 18)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        }
    }
}

// MARK: - Bubble Shape with Tail
struct BubbleShape: Shape {
    let isCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let radius: CGFloat = 18
        let tailWidth: CGFloat = 10
        let tailHeight: CGFloat = 8

        var path = Path()

        if isCurrentUser {
            // Start from bottom-right (where tail is)
            path.move(to: CGPoint(x: width, y: height - tailHeight))

            // Tail curve
            path.addQuadCurve(
                to: CGPoint(x: width - tailWidth, y: height - tailHeight - 4),
                control: CGPoint(x: width - 2, y: height - tailHeight - 2)
            )

            // Bottom-right corner (no radius on tail side)
            path.addLine(to: CGPoint(x: width - tailWidth, y: height - radius))

            // Right side
            path.addLine(to: CGPoint(x: width - tailWidth, y: radius))

            // Top-right corner
            path.addQuadCurve(
                to: CGPoint(x: width - tailWidth - radius, y: 0),
                control: CGPoint(x: width - tailWidth, y: 0)
            )

            // Top side
            path.addLine(to: CGPoint(x: radius, y: 0))

            // Top-left corner
            path.addQuadCurve(
                to: CGPoint(x: 0, y: radius),
                control: CGPoint(x: 0, y: 0)
            )

            // Left side
            path.addLine(to: CGPoint(x: 0, y: height - radius))

            // Bottom-left corner
            path.addQuadCurve(
                to: CGPoint(x: radius, y: height - tailHeight - 4),
                control: CGPoint(x: 0, y: height - tailHeight - 4)
            )

            // Bottom side
            path.addLine(to: CGPoint(x: width - tailWidth, y: height - tailHeight - 4))

        } else {
            // Start from bottom-left (where tail is)
            path.move(to: CGPoint(x: 0, y: height - tailHeight))

            // Tail curve
            path.addQuadCurve(
                to: CGPoint(x: tailWidth, y: height - tailHeight - 4),
                control: CGPoint(x: 2, y: height - tailHeight - 2)
            )

            // Bottom-left corner (no radius on tail side)
            path.addLine(to: CGPoint(x: tailWidth, y: height - radius))

            // Left side going up
            path.addLine(to: CGPoint(x: tailWidth, y: radius))

            // Top-left corner
            path.addQuadCurve(
                to: CGPoint(x: tailWidth + radius, y: 0),
                control: CGPoint(x: tailWidth, y: 0)
            )

            // Top side
            path.addLine(to: CGPoint(x: width - radius, y: 0))

            // Top-right corner
            path.addQuadCurve(
                to: CGPoint(x: width, y: radius),
                control: CGPoint(x: width, y: 0)
            )

            // Right side
            path.addLine(to: CGPoint(x: width, y: height - radius))

            // Bottom-right corner
            path.addQuadCurve(
                to: CGPoint(x: width - radius, y: height - tailHeight - 4),
                control: CGPoint(x: width, y: height - tailHeight - 4)
            )

            // Bottom side
            path.addLine(to: CGPoint(x: tailWidth, y: height - tailHeight - 4))
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview("Modern Chat Bubbles") {
    ScrollView {
        VStack(spacing: 8) {
            ModernChatBubbleView(
                text: "Hey! How are you doing today?",
                isCurrentUser: false,
                timestamp: .now,
                isRead: true
            )

            ModernChatBubbleView(
                text: "I'm doing great, thanks for asking! Just finished a really productive day at work.",
                isCurrentUser: true,
                timestamp: .now,
                isRead: true
            )

            ModernChatBubbleView(
                text: "That's awesome to hear! What did you work on?",
                isCurrentUser: false,
                timestamp: .now,
                isRead: false
            )

            ModernChatBubbleView(
                text: "Building a fancy new chat UI with SwiftUI. It's turning out really nice with bubble tails and smooth animations!",
                isCurrentUser: true,
                timestamp: .now,
                isRead: false
            )

            ModernChatBubbleView(
                text: "Short reply",
                isCurrentUser: false,
                timestamp: .now
            )

            ModernChatBubbleView(
                text: "OK",
                isCurrentUser: true,
                timestamp: .now
            )
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Bubble without tail") {
    VStack(spacing: 8) {
        ModernChatBubbleView(
            text: "Message without tail",
            isCurrentUser: true,
            showTail: false
        )

        ModernChatBubbleView(
            text: "Also without tail",
            isCurrentUser: false,
            showTail: false
        )
    }
    .padding()
}
