//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.06.2025.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abTestManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var createAccountTest: Bool = false
    @State private var onboardingCommunityTest: Bool = false
    @State private var categoryRowTest: CategoryRowTestOption = .default
    
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
                loadABTest()
            }
        }
    }
}

// MARK: - Load
private extension DevSettingsView {
    
    func loadABTest() {
        createAccountTest = abTestManager.activeTests.createAccountTest
        onboardingCommunityTest = abTestManager.activeTests.onboardingCommunityTest
        categoryRowTest = abTestManager.activeTests.categoryRowTest
    }
}

// MARK: - SectionViews
private extension DevSettingsView {
    
    var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                onBackButtonTap()
            }
    }
    
    var abTestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $createAccountTest)
                .onChange(
                    of: createAccountTest,
                    handleCreateAccountChange
                )
            
            Toggle("Onboarding Community Test", isOn: $onboardingCommunityTest)
                .onChange(
                    of: onboardingCommunityTest,
                    handleOnboardingCommunityChange
                )

            Picker("Category Row Test", selection: $categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: categoryRowTest, handleOnCategoryRowOptionChange)

        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    var authInfoSection: some View {
        Section {
            let array = authManager
                .auth?
                .eventParameters
                .asAlphabeticalArray ?? []
            
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    var userInfoSection: some View {
        Section {
            let array = userManager
                .currentUser?
                .eventParameters
                .asAlphabeticalArray ?? []
            
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    var deviceInfoSection: some View {
        Section {
            let array = Utilities
                .eventParameters
                .asAlphabeticalArray
            
            ForEach(array, id: \.key) { item in
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

// MARK: - Action
private extension DevSettingsView {
    
    func onBackButtonTap() {
        dismiss()
    }
    
    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.createAccountTest
        ) { tests in
            tests.update(createAccountTest: newValue)
        }
    }
    
    func handleOnboardingCommunityChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.onboardingCommunityTest
        ) { tests in
            tests.update(onboardingCommunityTest: newValue)
        }
    }
    
    func handleOnCategoryRowOptionChange(
        oldValue: CategoryRowTestOption,
        newValue: CategoryRowTestOption
    ) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.categoryRowTest
        ) { tests in
            tests.update(categoryRowTest: newValue)
        }
    }
    
    func updateTest<T: Equatable>(
        property: inout T,
        newValue: T,
        savedValue: T,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = abTestManager.activeTests
                updateAction(&tests)
                try abTestManager.override(updateTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
