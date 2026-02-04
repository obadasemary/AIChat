//
//  ReactionPickerView.swift
//  AIChat
//
//  Apple-style reaction picker with horizontal layout
//

import SwiftUI

struct ReactionPickerView: View {

    let onReactionSelected: (MessageReaction) -> Void

    private let reactions: [MessageReaction] = MessageReaction.allCases
    private let buttonSize: CGFloat = 36

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(reactions, id: \.self) { reaction in
                    Button {
                        onReactionSelected(reaction)
                        triggerHaptic(.medium)
                    } label: {
                        Text(reaction.emoji)
                            .font(.system(size: 24))
                            .frame(width: buttonSize, height: buttonSize)
                            .background(
                                Circle()
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: 280)
        .background(
            Capsule()
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        )
        .transition(.scale.combined(with: .opacity))
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview("Reaction Picker") {
    VStack {
        Spacer()
        ReactionPickerView { reaction in
            print("Selected: \(reaction.emoji)")
        }
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(uiColor: .systemGroupedBackground))
}
