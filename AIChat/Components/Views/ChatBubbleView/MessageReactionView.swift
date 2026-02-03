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
            HStack(spacing: 4) {
                ForEach(Array(reactionCounts.keys), id: \.self) { reaction in
                    if let count = reactionCounts[reaction], count > 0 {
                        reactionBadge(reaction: reaction, count: count)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
            .padding(.horizontal, 8)
            .padding(.top, -8)
        }
    }

    private var reactionCounts: [MessageReaction: Int] {
        var counts: [MessageReaction: Int] = [:]
        for reaction in reactions.values {
            counts[reaction, default: 0] += 1
        }
        return counts
    }

    private func reactionBadge(reaction: MessageReaction, count: Int) -> some View {
        HStack(spacing: 2) {
            Text(reaction.emoji)
                .font(.caption)

            if count > 1 {
                Text("\(count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
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
