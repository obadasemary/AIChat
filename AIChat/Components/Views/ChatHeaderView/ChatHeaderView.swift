//
//  ChatHeaderView.swift
//  AIChat
//
//  A modern chat header view with avatar and status
//  similar to WhatsApp and iMessage navigation bar.
//

import SwiftUI

struct ChatHeaderView: View {

    let name: String
    let subtitle: String?
    let avatarImageUrl: String?
    let isOnline: Bool
    let isTyping: Bool
    let onAvatarTapped: (() -> Void)?
    let onBackTapped: (() -> Void)?

    init(
        name: String,
        subtitle: String? = nil,
        avatarImageUrl: String? = nil,
        isOnline: Bool = true,
        isTyping: Bool = false,
        onAvatarTapped: (() -> Void)? = nil,
        onBackTapped: (() -> Void)? = nil
    ) {
        self.name = name
        self.subtitle = subtitle
        self.avatarImageUrl = avatarImageUrl
        self.isOnline = isOnline
        self.isTyping = isTyping
        self.onAvatarTapped = onAvatarTapped
        self.onBackTapped = onBackTapped
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar with online indicator
            avatarSection

            // Name and status
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                statusText
            }

            Spacer()
        }
    }

    private var avatarSection: some View {
        Button {
            onAvatarTapped?()
        } label: {
            ZStack(alignment: .bottomTrailing) {
                // Avatar image
                if let avatarImageUrl {
                    ImageLoaderView(urlString: avatarImageUrl)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.gray)
                        }
                }

                // Online indicator
                if isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .overlay {
                            Circle()
                                .stroke(Color(uiColor: .systemBackground), lineWidth: 2)
                        }
                        .offset(x: 2, y: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusText: some View {
        if isTyping {
            TypingStatusView()
        } else if let subtitle {
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        } else if isOnline {
            Text("Online")
                .font(.caption)
                .foregroundStyle(.green)
        }
    }
}

// MARK: - Typing Status View with Animation
struct TypingStatusView: View {

    @State private var dotCount = 0

    var body: some View {
        HStack(spacing: 0) {
            Text("typing")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(String(repeating: ".", count: dotCount))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .leading)
        }
        .onAppear {
            startTypingAnimation()
        }
    }

    private func startTypingAnimation() {
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.4))
                dotCount = (dotCount % 3) + 1
            }
        }
    }
}

// MARK: - Chat Navigation Title View (for toolbar)
struct ChatNavigationTitleView: View {

    let name: String
    let avatarImageUrl: String?
    let isOnline: Bool
    let isTyping: Bool
    let onTapped: (() -> Void)?

    init(
        name: String,
        avatarImageUrl: String? = nil,
        isOnline: Bool = true,
        isTyping: Bool = false,
        onTapped: (() -> Void)? = nil
    ) {
        self.name = name
        self.avatarImageUrl = avatarImageUrl
        self.isOnline = isOnline
        self.isTyping = isTyping
        self.onTapped = onTapped
    }

    var body: some View {
        Button {
            onTapped?()
        } label: {
            HStack(spacing: 10) {
                // Avatar
                ZStack(alignment: .bottomTrailing) {
                    if let avatarImageUrl {
                        ImageLoaderView(urlString: avatarImageUrl)
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                    }

                    if isOnline {
                        Circle()
                            .fill(.green)
                            .frame(width: 10, height: 10)
                            .overlay {
                                Circle()
                                    .stroke(Color(uiColor: .systemBackground), lineWidth: 2)
                            }
                            .offset(x: 1, y: 1)
                    }
                }

                // Name and status
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if isTyping {
                        TypingStatusView()
                    } else if isOnline {
                        Text("Online")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Chat Header View") {
    VStack(spacing: 20) {
        ChatHeaderView(
            name: "John Doe",
            subtitle: nil,
            avatarImageUrl: Constants.randomImage,
            isOnline: true,
            isTyping: false
        )
        .padding()
        .background(Color(uiColor: .systemBackground))

        ChatHeaderView(
            name: "Jane Smith",
            subtitle: "Last seen today at 3:45 PM",
            avatarImageUrl: Constants.randomImage,
            isOnline: false,
            isTyping: false
        )
        .padding()
        .background(Color(uiColor: .systemBackground))

        ChatHeaderView(
            name: "AI Assistant",
            avatarImageUrl: Constants.randomImage,
            isOnline: true,
            isTyping: true
        )
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Chat Navigation Title") {
    NavigationStack {
        Text("Chat Content")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ChatNavigationTitleView(
                        name: "AI Friend",
                        avatarImageUrl: Constants.randomImage,
                        isOnline: true,
                        isTyping: true
                    )
                }
            }
    }
}

#Preview("Navigation with Typing") {
    NavigationStack {
        VStack {
            Text("Messages would go here")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ChatNavigationTitleView(
                    name: "Assistant",
                    avatarImageUrl: Constants.randomImage,
                    isOnline: true,
                    isTyping: true
                )
            }
        }
    }
}
