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
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
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
    }
}

// MARK: - SectionViews
private extension DevSettingsView {
    
    var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                viewModel.onBackButtonTap {
                    dismiss()
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
    DevSettingsView(
        viewModel: DevSettingsViewModel(
            devSettingsUseCase: DevSettingsUseCase(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}
