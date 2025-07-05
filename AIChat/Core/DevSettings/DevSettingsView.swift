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
        } header: {
            Text("AB Test")
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
    
    func loadABTest() {
        createAccountTest = abTestManager.activeTests.createAccountTest
    }
    
    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        if newValue != abTestManager.activeTests.createAccountTest {
            do {
                var tests = abTestManager.activeTests
                tests.update(createAccountTest: newValue)
                try abTestManager.override(updateTests: tests)
            } catch {
                createAccountTest = abTestManager.activeTests.createAccountTest
            }
        }
    }
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
