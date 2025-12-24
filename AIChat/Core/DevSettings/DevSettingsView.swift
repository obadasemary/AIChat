//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.06.2025.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {

    @State var presenter: DevSettingsPresenter
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
                presenter.loadABTest()
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
                selection: $presenter.colorSchemePreference
            ) {
                ForEach(ColorSchemePreference.allCases, id: \.self) { preference in
                    Text(preference.rawValue)
                        .id(preference)
                }
            }
            .onChange(
                of: presenter.colorSchemePreference,
                presenter.handleColorSchemeChange
            )
        } header: {
            Text("Appearance")
        }
        .font(.caption)
    }
    
    var backButtonView: some View {
        if #available(iOS 26.0, *) {
            return Button(role: .close) {
                presenter.onBackButtonTap()
            }
            .tint(.accent)
        } else {
            return Image(systemName: "xmark")
                .font(.subheadline)
                .padding(4)
                .anyButton {
                    presenter.onBackButtonTap()
                }
        }
    }
    
    var abTestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $presenter.createAccountTest)
                .onChange(
                    of: presenter.createAccountTest,
                    presenter.handleCreateAccountChange
                )
            
            Toggle("Onboarding Community Test", isOn: $presenter.onboardingCommunityTest)
                .onChange(
                    of: presenter.onboardingCommunityTest,
                    presenter.handleOnboardingCommunityChange
                )

            Picker("Category Row Test", selection: $presenter.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(
                of: presenter.categoryRowTest,
                presenter.handleOnCategoryRowOptionChange
            )

            Picker("Paywall Option", selection: $presenter.paywallOption) {
                ForEach(PaywallOptional.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(
                of: presenter.paywallOption,
                presenter.handlePaywallOptionChange
            )

        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    var authInfoSection: some View {
        Section {
            ForEach(presenter.authData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    var userInfoSection: some View {
        Section {
            ForEach(presenter.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    var deviceInfoSection: some View {
        Section {
            ForEach(presenter.utilities, id: \.key) { item in
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
