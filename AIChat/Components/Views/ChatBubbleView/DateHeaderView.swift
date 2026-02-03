//
//  DateHeaderView.swift
//  AIChat
//
//  A date header view for grouping messages by date
//  similar to iMessage and WhatsApp.
//

import SwiftUI

struct DateHeaderView: View {

    let date: Date

    private var formattedDate: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: .now, toGranularity: .weekOfYear) {
            // Same week - show day name
            return date.formatted(.dateTime.weekday(.wide))
        } else if calendar.isDate(date, equalTo: .now, toGranularity: .year) {
            // Same year - show month and day
            return date.formatted(.dateTime.month(.wide).day())
        } else {
            // Different year - show full date
            return date.formatted(.dateTime.month(.abbreviated).day().year())
        }
    }

    var body: some View {
        Text(formattedDate)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(uiColor: .systemGray5))
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

// MARK: - Time Separator View
struct TimeSeparatorView: View {

    let date: Date

    var body: some View {
        HStack {
            VStack { Divider() }

            Text(date.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)

            VStack { Divider() }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Message Group Helper
struct MessageGroup: Identifiable {
    let id: String
    let date: Date
    var messages: [ChatMessageModel]

    init(date: Date, messages: [ChatMessageModel] = []) {
        self.id = date.formatted(date: .numeric, time: .omitted)
        self.date = date
        self.messages = messages
    }
}

extension Array where Element == ChatMessageModel {
    /// Groups messages by date for display with date headers
    func groupedByDate() -> [MessageGroup] {
        let calendar = Calendar.current

        var groups: [MessageGroup] = []
        var currentGroup: MessageGroup?

        let sortedMessages = self.sorted { $0.dateCreatedCalculated < $1.dateCreatedCalculated }

        for message in sortedMessages {
            let messageDate = message.dateCreatedCalculated
            let startOfDay = calendar.startOfDay(for: messageDate)

            if let group = currentGroup,
               calendar.isDate(group.date, inSameDayAs: messageDate) {
                // Same day, add to current group
                currentGroup?.messages.append(message)
            } else {
                // Different day, save current group and start new one
                if let group = currentGroup {
                    groups.append(group)
                }
                currentGroup = MessageGroup(date: startOfDay, messages: [message])
            }
        }

        // Don't forget the last group
        if let group = currentGroup {
            groups.append(group)
        }

        return groups
    }

    /// Determines if a message should show its avatar based on consecutive messages
    func shouldShowAvatar(for message: ChatMessageModel, currentUserId: String?) -> Bool {
        guard let index = self.firstIndex(where: { $0.id == message.id }) else {
            return true
        }

        // Always show avatar for non-current user messages if it's the last in a sequence
        let isCurrentUser = message.authorId == currentUserId

        if isCurrentUser {
            return false // Current user doesn't show avatar
        }

        // Check if next message is from same author
        let nextIndex = index + 1
        if nextIndex < self.count {
            let nextMessage = self[nextIndex]
            if nextMessage.authorId == message.authorId {
                // Check if within same time window (5 minutes)
                let timeDiff = nextMessage.dateCreatedCalculated
                    .timeIntervalSince(message.dateCreatedCalculated)
                if timeDiff < 300 { // 5 minutes
                    return false
                }
            }
        }

        return true
    }

    /// Determines if a message should show its bubble tail
    func shouldShowTail(for message: ChatMessageModel) -> Bool {
        guard let index = self.firstIndex(where: { $0.id == message.id }) else {
            return true
        }

        // Check if next message is from same author
        let nextIndex = index + 1
        if nextIndex < self.count {
            let nextMessage = self[nextIndex]
            if nextMessage.authorId == message.authorId {
                // Check if within same time window (2 minutes)
                let timeDiff = nextMessage.dateCreatedCalculated
                    .timeIntervalSince(message.dateCreatedCalculated)
                if timeDiff < 120 { // 2 minutes
                    return false
                }
            }
        }

        return true
    }
}

// MARK: - Preview
#Preview("Date Headers") {
    VStack(spacing: 16) {
        DateHeaderView(date: .now)
        DateHeaderView(date: .now.addingTimeInterval(-86400)) // Yesterday
        DateHeaderView(date: .now.addingTimeInterval(-86400 * 3)) // 3 days ago
        DateHeaderView(date: .now.addingTimeInterval(-86400 * 30)) // 30 days ago
        DateHeaderView(date: .now.addingTimeInterval(-86400 * 400)) // Over a year ago
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Time Separator") {
    VStack(spacing: 16) {
        TimeSeparatorView(date: .now)
        TimeSeparatorView(date: .now.addingTimeInterval(-3600))
    }
    .padding()
}

#Preview("Message Grouping") {
    let messages = ChatMessageModel.mocks
    let groups = messages.groupedByDate()

    return List {
        ForEach(groups) { group in
            Section {
                ForEach(group.messages) { message in
                    Text(message.content?.message ?? "No content")
                }
            } header: {
                DateHeaderView(date: group.date)
            }
        }
    }
}
