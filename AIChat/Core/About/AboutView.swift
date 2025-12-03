//
//  AboutView.swift
//  AIChat
//
//  Created by Claude Code on 01.12.2025.
//

import SwiftUI

struct AboutView: View {

    @State var viewModel: AboutViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                appInfoSection
                aboutSection
                developerSection
                legalSection

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("About")
        .screenAppearAnalytics(name: "AboutView")
    }
}

// MARK: - Section Views
private extension AboutView {

    var appInfoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 16)

            Text("AIChat")
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(viewModel.appVersion)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Build \(viewModel.buildNumber)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }

    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                Text("AIChat is your intelligent AI companion powered by advanced language models. Have natural conversations, get helpful answers, and explore the possibilities of AI.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
        }
    }

    var developerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Developer")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                HStack {
                    Text("Company")
                    Spacer()
                    Text("SamuraiStudios Inc.")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)

                Divider()
                    .padding(.leading, 16)

                HStack {
                    Text("Website")
                    Spacer()
                    Text("SamuraiStudios.com")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)

                Divider()
                    .padding(.leading, 16)

                Button {
                    viewModel.onContactSupportPressed()
                } label: {
                    HStack {
                        Text("Contact Support")
                            .foregroundStyle(.blue)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
        }
    }

    var legalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legal")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                Button {
                    viewModel.onPrivacyPolicyPressed()
                } label: {
                    HStack {
                        Text("Privacy Policy")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }

                Divider()
                    .padding(.leading, 16)

                Button {
                    viewModel.onTermsOfServicePressed()
                } label: {
                    HStack {
                        Text("Terms of Service")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)

            Text("© \(Calendar.current.component(.year, from: Date()).description) SamuraiStudios Inc. All rights reserved.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let aboutBuilder = AboutBuilder(container: container)

    return RouterView { router in
        aboutBuilder.buildAboutView(router: router)
    }
    .previewEnvironment()
}
