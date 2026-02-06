//
//  TokenUsageView.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import SwiftUI

struct TokenUsageView: View {

    @State var viewModel: TokenUsageViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statusSection

                if viewModel.isLoading {
                    ProgressView("Loading usage…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.entries.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.entries) { entry in
                        TokenUsageCardView(entry: entry)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Token Usage")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Refresh") {
                    viewModel.refreshTapped()
                }
                .disabled(viewModel.isLoading)
            }
        }
        .task {
            await viewModel.loadUsage()
        }
        .screenAppearAnalytics(name: "TokenUsageView")
    }
}

private extension TokenUsageView {

    var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Usage Overview")
                .font(.headline)

            Text("Connect your provider dashboards to pull live Claude and Codex usage.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let lastUpdated = viewModel.lastUpdated {
                Text("Last updated \(Self.relativeDateFormatter.localizedString(for: lastUpdated, relativeTo: Date()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No usage data yet")
                .font(.headline)

            Text("Add provider API keys to fetch usage and stay on top of your token limits.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

private struct TokenUsageCardView: View {
    let entry: TokenUsageEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.providerName)
                        .font(.headline)
                    Text(entry.productName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                StatusBadge(title: entry.status.title)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Used")
                    Spacer(minLength: 0)
                    Text(Self.formatTokens(entry.tokensUsed))
                        .fontWeight(.semibold)
                }

                if let tokenLimit = entry.tokenLimit {
                    HStack {
                        Text("Limit")
                        Spacer(minLength: 0)
                        Text(Self.formatTokens(tokenLimit))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Limit unavailable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let usageFraction = entry.usageFraction {
                    ProgressView(value: usageFraction)
                        .tint(usageFraction > 0.8 ? .red : .blue)
                }
            }

            Text(entry.status.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let billingPeriod = entry.billingPeriod {
                Text("Billing period: \(Self.periodFormatter.string(from: billingPeriod.start)) – \(Self.periodFormatter.string(from: billingPeriod.end))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }

    private static func formatTokens(_ value: Int) -> String {
        numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private static let periodFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

private struct StatusBadge: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(uiColor: .secondarySystemBackground))
            .foregroundStyle(.secondary)
            .clipShape(Capsule())
    }
}

private extension TokenUsageView {
    static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}

#Preview {
    let container = DevPreview.shared.container

    let builder = TokenUsageBuilder(container: container)

    return RouterView { router in
        builder.buildTokenUsageView(router: router)
    }
    .previewEnvironment(isSignedIn: true)
}
