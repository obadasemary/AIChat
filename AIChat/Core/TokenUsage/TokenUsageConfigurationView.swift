//
//  TokenUsageConfigurationView.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import SwiftUI

struct TokenUsageConfigurationView: View {

    let provider: TokenUsageProvider
    let initialAPIKey: String
    let onSave: (String) -> Void
    let onClear: () -> Void
    let onCancel: () -> Void

    @State private var apiKey: String
    @State private var isSecureEntry = true

    init(
        provider: TokenUsageProvider,
        initialAPIKey: String,
        onSave: @escaping (String) -> Void,
        onClear: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.provider = provider
        self.initialAPIKey = initialAPIKey
        self.onSave = onSave
        self.onClear = onClear
        self.onCancel = onCancel
        _apiKey = State(initialValue: initialAPIKey)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    credentialSection
                    actionSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("\(provider.displayName) Configuration")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

private extension TokenUsageConfigurationView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Connect your \(provider.displayName) account to pull usage stats.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Your API key is stored securely on this device.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }

    var credentialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("API Key")
                .font(.headline)

            HStack(spacing: 8) {
                if isSecureEntry {
                    SecureField("Paste your API key", text: $apiKey)
                } else {
                    TextField("Paste your API key", text: $apiKey)
                }

                Button(isSecureEntry ? "Show" : "Hide") {
                    isSecureEntry.toggle()
                }
                .font(.caption)
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }

    var actionSection: some View {
        VStack(spacing: 12) {
            Button("Save") {
                onSave(apiKey)
            }
            .callToActionButton()

            if !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !initialAPIKey.isEmpty {
                Button(role: .destructive) {
                    apiKey = ""
                    onClear()
                } label: {
                    Text("Clear Key")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TokenUsageConfigurationView(
        provider: .codex,
        initialAPIKey: "",
        onSave: { _ in },
        onClear: { },
        onCancel: { }
    )
    .previewEnvironment(isSignedIn: true)
}
