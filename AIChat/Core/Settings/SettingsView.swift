//
//  SettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AppState.self) private var appState
    
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = true
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
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
                    onDeleteAccountPressed()
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
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
    
    func onSignOutPressed() {
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteAccountPressed() {
        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our servers and you will be logged out forever.",
            buttons: {
                AnyView(
                    Button("Delete Account", role: .destructive) {
                        onDeleteAccountConfirmationPressed()
                    }
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmationPressed() {
        Task {
            do {
                let userId = try authManager.getAuthId()
                
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleteCurrentUser()
                async let deleteAvatar: () = avatarManager
                    .removeAuthorIdFromAllUserAvatars(userId: userId)
                async let deleteChats: () = chatManager.deleteAllChatsForUser(
                    userId: userId
                )
                
                let (_, _, _, _) = await (
                    try deleteAuth,
                    try deleteUser,
                    try deleteAvatar,
                    try deleteChats
                )
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
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

#Preview("No Auth") {
    SettingsView()
        .environment(UserManager(services: MockUserServices(currentUser: nil)))
        .environment(AuthManager(service: MockAuthService(currentUser: nil)))
        .previewEnvironment(isSignedIn: false)
}

#Preview("Anonymous") {
    SettingsView()
        .environment(
            AuthManager(
                service: MockAuthService(
                    currentUser: UserAuthInfo.mock(
                        isAnonymous: true
                    )
                )
            )
        )
        .environment(
            UserManager(services: MockUserServices(currentUser: .mock))
        )
        .previewEnvironment()
}

#Preview("Not anonymous") {
    SettingsView()
        .environment(
            AuthManager(
                service: MockAuthService(
                    currentUser: UserAuthInfo.mock(
                        isAnonymous: false
                    )
                )
            )
        )
        .environment(
            UserManager(services: MockUserServices(currentUser: .mock))
        )
        .previewEnvironment()
}
