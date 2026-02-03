//
//  TypingIndicatorView.swift
//  AIChat
//
//  An animated typing indicator with bouncing dots
//  similar to iMessage and WhatsApp.
//

import SwiftUI

struct TypingIndicatorView: View {

    let avatarImageUrl: String?
    let showAvatar: Bool

    @State private var animatingDots: [Bool] = [false, false, false]

    private let dotSize: CGFloat = 8
    private let animationDuration: Double = 0.4
    private let delayBetweenDots: Double = 0.15

    init(
        avatarImageUrl: String? = nil,
        showAvatar: Bool = true
    ) {
        self.avatarImageUrl = avatarImageUrl
        self.showAvatar = showAvatar
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            avatarView

            bubbleContent

            Spacer(minLength: 100)
        }
        .padding(.horizontal, 8)
        .onAppear {
            startAnimation()
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if showAvatar {
            if let avatarImageUrl {
                ImageLoaderView(urlString: avatarImageUrl)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
        } else {
            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    private var bubbleContent: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: animatingDots[index] ? -4 : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: BubbleShape.cornerRadius)
                .fill(Color(uiColor: .systemGray5))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }

    private func startAnimation() {
        // Create a continuous animation loop for each dot
        for index in 0..<3 {
            let delay = Double(index) * delayBetweenDots
            animateDot(at: index, delay: delay)
        }
    }

    private func animateDot(at index: Int, delay: Double) {
        Task { @MainActor in
            // Initial delay for staggered animation
            try? await Task.sleep(for: .seconds(delay))

            // Continuous animation loop
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    animatingDots[index] = true
                }

                try? await Task.sleep(for: .seconds(animationDuration))

                withAnimation(.easeInOut(duration: animationDuration)) {
                    animatingDots[index] = false
                }

                try? await Task.sleep(for: .seconds(animationDuration + (delayBetweenDots * 2)))
            }
        }
    }
}

// MARK: - Alternative Pulsing Typing Indicator
struct PulsingTypingIndicatorView: View {

    let avatarImageUrl: String?
    let showAvatar: Bool

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6

    init(
        avatarImageUrl: String? = nil,
        showAvatar: Bool = true
    ) {
        self.avatarImageUrl = avatarImageUrl
        self.showAvatar = showAvatar
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            avatarView

            bubbleContent

            Spacer(minLength: 100)
        }
        .padding(.horizontal, 8)
        .onAppear {
            startPulsingAnimation()
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if showAvatar {
            if let avatarImageUrl {
                ImageLoaderView(urlString: avatarImageUrl)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
        } else {
            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    private var bubbleContent: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            BubbleShape(isCurrentUser: false)
                .fill(Color(uiColor: .systemGray5))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }

    private func startPulsingAnimation() {
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            scale = 1.1
            opacity = 1.0
        }
    }
}

// MARK: - Preview
#Preview("Typing Indicator - Bouncing") {
    VStack(spacing: 20) {
        TypingIndicatorView(
            avatarImageUrl: Constants.randomImage,
            showAvatar: true
        )

        TypingIndicatorView(
            showAvatar: false
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Typing Indicator - Pulsing") {
    VStack(spacing: 20) {
        PulsingTypingIndicatorView(
            avatarImageUrl: Constants.randomImage,
            showAvatar: true
        )

        PulsingTypingIndicatorView(
            showAvatar: false
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("In Chat Context") {
    VStack(spacing: 8) {
        MessageRowView(
            message: ChatMessageModel(
                id: "1",
                chatId: "chat1",
                authorId: "user1",
                content: AIChatModel(role: .user, message: "Hey, what do you think about this?"),
                seenByIds: ["user1"],
                dateCreated: .now
            ),
            isCurrentUser: true,
            currentUserProfileColor: .blue
        )

        TypingIndicatorView(
            avatarImageUrl: Constants.randomImage,
            showAvatar: true
        )
    }
    .padding(.vertical)
    .background(Color(uiColor: .systemGroupedBackground))
}
