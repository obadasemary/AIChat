//
//  SettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = true
    @State private var showCreateAccountView: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView) {
                CreateAccountView()
                    .presentationDetents([.medium])
            }
        }
    }
    
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & Backup Account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account Status: \(isPremium ? "PREMIUM" : "FREE")")
                
                Spacer(minLength: 0)
                
                if isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {
                
            }
            .disabled(!isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchase")
        }
    }
    
    private var applicationSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Version")
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact Support")
                .foregroundStyle(.orange)
                .rowFormatting()
                .anyButton(.highlight) {
                    
                }
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("© \(Calendar.current.component(.year, from: Date()).description) Obada Inc.\n All rights reserved. \n Learn more at https://github.com/obadasemary")
                .foregroundStyle(.secondary)
                .baselineOffset(6)
        }
    }
    
    func onSignOutPressed() {
        dismiss()
        
        Task {
            try? await Task.sleep(for: .seconds(1))
            appState.updateViewState(showTabBarView: false)
        }
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background {
                Color(uiColor: .systemBackground)
            }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
