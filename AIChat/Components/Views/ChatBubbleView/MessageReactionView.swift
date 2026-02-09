//
//  MessageReactionView.swift
//  AIChat
//
//  A view to display message reactions with count
//

import SwiftUI

struct MessageReactionView: View {

    let reactions: [String: MessageReaction]
    let isCurrentUser: Bool

    var body: some View {
        if !reactions.isEmpty {
            HStack(spacing: 6) {
                ForEach(sortedReactions, id: \.reaction) { item in
                    // swiftlint:disable empty_count
                    if item.count > 0 {
                        reactionBadge(reaction: item.reaction, count: item.count)
                    }
                    // swiftlint:enable empty_count
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            )
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
            .padding(.horizontal, 8)
            .padding(.top, -10)
        }
    }

    private var reactionCounts: [MessageReaction: Int] {
        var counts: [MessageReaction: Int] = [:]
        for reaction in reactions.values {
            counts[reaction, default: 0] += 1
        }
        return counts
    }

    private var sortedReactions: [(reaction: MessageReaction, count: Int)] {
        reactionCounts
            .map { (reaction: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private func reactionBadge(reaction: MessageReaction, count: Int) -> some View {
        HStack(spacing: 3) {
            Text(reaction.emoji)
                .font(.system(size: 14))

            if count > 1 {
                Text("\(count)")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(uiColor: .quaternarySystemFill))
        )
    }
}

// MARK: - Preview
#Preview("Message Reactions") {
    VStack(spacing: 16) {
        MessageReactionView(
            reactions: [
                "user1": .like,
                "user2": .love,
                "user3": .like
            ],
            isCurrentUser: false
        )

        MessageReactionView(
            reactions: [
                "user1": .love,
                "user2": .love,
                "user3": .love,
                "user4": .love
            ],
            isCurrentUser: true
        )

        MessageReactionView(
            reactions: [
                "user1": .like,
                "user2": .love,
                "user3": .laugh,
                "user4": .wow
            ],
            isCurrentUser: false
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
