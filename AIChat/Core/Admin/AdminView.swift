//
//  AdminView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI

struct AdminView: View {

    @State var viewModel: AdminViewModel

    var body: some View {
        List {
            userInfoSection
            serviceHealthSection
            usageStatisticsSection
            abTestsSection
            systemToolsSection
        }
        .navigationTitle("Admin")
        .screenAppearAnalytics(name: "AdminView")
        .onFirstAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Sections
private extension AdminView {

    var userInfoSection: some View {
        Section {
            infoRow(title: "User ID", value: viewModel.userId)
            infoRow(title: "Email", value: viewModel.userEmail)
            infoRow(title: "Anonymous", value: viewModel.isAnonymous ? "Yes" : "No")
            infoRow(title: "Created", value: viewModel.accountCreationDate)
            infoRow(title: "Last Sign In", value: viewModel.lastSignInDate)
            infoRow(title: "Onboarding", value: viewModel.didCompleteOnboarding ? "Complete" : "Incomplete")
            infoRow(title: "Status", value: viewModel.premiumStatus)
            if viewModel.isPremium {
                infoRow(title: "Product ID", value: viewModel.premiumProductId)
                infoRow(title: "Expires", value: viewModel.premiumExpirationDate)
            }
        } header: {
            Text("User Info")
        }
    }

    var serviceHealthSection: some View {
        Section {
            HStack {
                Text("Network")
                Spacer()
                Circle()
                    .fill(viewModel.isNetworkConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(viewModel.networkStatus)
                    .foregroundStyle(.secondary)
            }
            infoRow(title: "Connection Type", value: viewModel.connectionType)
            infoRow(title: "Push Notifications", value: viewModel.pushStatus)
        } header: {
            Text("Service Health")
        }
    }

    var usageStatisticsSection: some View {
        Section {
            if viewModel.isLoading {
                HStack {
                    Text("Loading...")
                    Spacer()
                    ProgressView()
                }
            } else {
                infoRow(title: "Chats", value: "\(viewModel.chatCount)")
                infoRow(title: "Avatars Created", value: "\(viewModel.avatarCount)")
                infoRow(title: "Bookmarks", value: "\(viewModel.bookmarkCount)")
            }
        } header: {
            Text("Usage Statistics")
        }
    }

    var abTestsSection: some View {
        Section {
            infoRow(title: "Create Account Test", value: viewModel.createAccountTest ? "Enabled" : "Disabled")
            infoRow(title: "Onboarding Community", value: viewModel.onboardingCommunityTest ? "Enabled" : "Disabled")
            infoRow(title: "Category Row", value: viewModel.categoryRowTest)
            infoRow(title: "Paywall Option", value: viewModel.paywallOption)
        } header: {
            Text("A/B Tests")
        } footer: {
            Text("Read-only view of active A/B test configurations")
        }
    }

    var systemToolsSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.onClearAllChatsPressed()
            } label: {
                HStack {
                    Text("Clear All Chats")
                    Spacer()
                    if viewModel.isDeleting {
                        ProgressView()
                    }
                }
            }
            .disabled(viewModel.isDeleting || viewModel.chatCount == 0)

            Button {
                viewModel.onRefreshDataPressed()
            } label: {
                HStack {
                    Text("Refresh Data")
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .disabled(viewModel.isLoading)
        } header: {
            Text("System Tools")
        }
    }

    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .font(.callout)
    }
}

#Preview {
    let container = DevPreview.shared.container
    let adminBuilder = AdminBuilder(container: container)

    return RouterView { router in
        NavigationStack {
            adminBuilder.buildAdminView(router: router)
        }
    }
    .previewEnvironment()
}
