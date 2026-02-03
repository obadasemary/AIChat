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
            RoundedRectangle(cornerRadius: BubbleShape.cornerRadius)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        }
    }
}

// MARK: - Bubble Shape with Tail
struct BubbleShape: Shape {
    let isCurrentUser: Bool
    static let cornerRadius: CGFloat = 18
    static let tailWidth: CGFloat = 10
    static let tailHeight: CGFloat = 8
    private static let tailYOffset: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        let radius = min(Self.cornerRadius, rect.height / 2)
        let tailWidth = Self.tailWidth
        let tailHeight = min(Self.tailHeight, rect.height / 2)
        let tailTopY = max(rect.minY + radius, rect.maxY - radius - tailHeight)
        let tailBottomY = min(rect.maxY - radius / 2, tailTopY + tailHeight + Self.tailYOffset)

        let bodyRect: CGRect
        if isCurrentUser {
            bodyRect = CGRect(
                x: rect.minX,
                y: rect.minY,
                width: rect.width - tailWidth,
                height: rect.height
            )
        } else {
            bodyRect = CGRect(
                x: rect.minX + tailWidth,
                y: rect.minY,
                width: rect.width - tailWidth,
                height: rect.height
            )
        }

        var path = Path(roundedRect: bodyRect, cornerRadius: radius)
        var tail = Path()

        if isCurrentUser {
            tail.move(to: CGPoint(x: bodyRect.maxX, y: tailTopY))
            tail.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: (tailTopY + tailBottomY) / 2),
                control: CGPoint(x: rect.maxX - 1, y: tailTopY + 1)
            )
            tail.addQuadCurve(
                to: CGPoint(x: bodyRect.maxX, y: tailBottomY),
                control: CGPoint(x: rect.maxX - 1, y: tailBottomY - 1)
            )
        } else {
            tail.move(to: CGPoint(x: bodyRect.minX, y: tailTopY))
            tail.addQuadCurve(
                to: CGPoint(x: rect.minX, y: (tailTopY + tailBottomY) / 2),
                control: CGPoint(x: rect.minX + 1, y: tailTopY + 1)
            )
            tail.addQuadCurve(
                to: CGPoint(x: bodyRect.minX, y: tailBottomY),
                control: CGPoint(x: rect.minX + 1, y: tailBottomY - 1)
            )
        }

        tail.closeSubpath()
        path.addPath(tail)
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
