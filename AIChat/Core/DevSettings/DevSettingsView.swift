//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.06.2025.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {

    @State var viewModel: DevSettingsViewModel
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                abTestSection
                authInfoSection
                userInfoSection
                deviceInfoSection
            }
            .navigationTitle("Dev Settings 🤫")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButtonView
                }
            }
            .screenAppearAnalytics(name: "DevSettings")
            .onFirstAppear {
                viewModel.loadABTest()
            }
        }
        .preferredColorScheme(colorSchemeManager.currentColorScheme)
    }
}

// MARK: - SectionViews
private extension DevSettingsView {
    
    var appearanceSection: some View {
        Section {
            Picker(
                "Appearance",
                selection: $viewModel.colorSchemePreference
            ) {
                ForEach(ColorSchemePreference.allCases, id: \.self) { preference in
                    Text(preference.rawValue)
                        .id(preference)
                }
            }
            .onChange(
                of: viewModel.colorSchemePreference,
                viewModel.handleColorSchemeChange
            )
        } header: {
            Text("Appearance")
        }
        .font(.caption)
    }
    
    var backButtonView: some View {
        if #available(iOS 26.0, *) {
            return Button(role: .close) {
                viewModel.onBackButtonTap()
            }
            .tint(.accent)
        } else {
            return Image(systemName: "xmark")
                .font(.subheadline)
                .padding(4)
                .anyButton {
                    viewModel.onBackButtonTap()
                }
        }
    }
    
    var abTestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $viewModel.createAccountTest)
                .onChange(
                    of: viewModel.createAccountTest,
                    viewModel.handleCreateAccountChange
                )
            
            Toggle("Onboarding Community Test", isOn: $viewModel.onboardingCommunityTest)
                .onChange(
                    of: viewModel.onboardingCommunityTest,
                    viewModel.handleOnboardingCommunityChange
                )

            Picker("Category Row Test", selection: $viewModel.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(
                of: viewModel.categoryRowTest,
                viewModel.handleOnCategoryRowOptionChange
            )

            Picker("Paywall Option", selection: $viewModel.paywallOption) {
                ForEach(PaywallOptional.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(
                of: viewModel.paywallOption,
                viewModel.handlePaywallOptionChange
            )

        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    var authInfoSection: some View {
        Section {
            ForEach(viewModel.authData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    var userInfoSection: some View {
        Section {
            ForEach(viewModel.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    var deviceInfoSection: some View {
        Section {
            ForEach(viewModel.utilities, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
    
    func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
}

#Preview {
    let container = DevPreview.shared.container
    let devSettingsBuilder = DevSettingsBuilder(container: container)

    return RouterView { router in
        devSettingsBuilder.buildDevSettingsView(router: router)
    }
    .previewEnvironment()
}
