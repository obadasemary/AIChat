//
//  SettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AppState.self) private var appState
    @Environment(LogManager.self) private var logManager
    
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = true
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var showRatingsModal: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
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
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $showRatingsModal) {
                ratingsModal
            }
        }
    }
}

// MARK: - Load
private extension SettingsView {
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
}

// MARK: - SectionViews
private extension SettingsView {
    
    var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                onEnjoyingAppNoPressed()
            }
        )
    }
    
    var accountSection: some View {
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
    
    var purchaseSection: some View {
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
    
    var applicationSection: some View {
        Section {
            Text("Rate us on the App Store")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    onRatingsPressed()
                }
                .removeListRowFormatting()
            
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
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    onContactUsPressed()
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
}

// MARK: - Action
private extension SettingsView {
    
    func onSignOutPressed() {
        logManager.trackEvent(event: Event.signOutStart)
        
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                logManager
                    .trackEvent(
                        event: Event.signOutSuccess
                    )
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager
                    .trackEvent(
                        event: Event.signOutFail(
                            error: error
                        )
                    )
            }
        }
    }
    
    func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
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
    
    func onDeleteAccountConfirmationPressed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfirm)
        
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
                
                logManager.deleteUserProfile()
                logManager
                    .trackEvent(
                        event: Event.deleteAccountSuccess
                    )
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager
                    .trackEvent(
                        event: Event.deleteAccountFail(
                            error: error
                        )
                    )
            }
        }
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
        logManager
            .trackEvent(
                event: Event.createAccountPressed
            )
    }
    
    func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)
        
        let email = "obada.semary@gmail.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString),
              UIApplication.shared.canOpenURL(url)
        else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func onRatingsPressed() {
        logManager.trackEvent(event: Event.ratingPressed)
        showRatingsModal = true
    }
    
    func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingNoPressed)
        showRatingsModal = false
    }
}

// MARK: - Event
private extension SettingsView {
    
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case createAccountPressed
        case contactUsPressed
        case ratingPressed
        case ratingYesPressed
        case ratingNoPressed
        

        var eventName: String {
            switch self {
            case .signOutStart: "SettingsView_SignOut_Start"
            case .signOutSuccess: "SettingsView_SignOut_Success"
            case .signOutFail: "SettingsView_SignOut_Fail"
            case .deleteAccountStart: "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm: "SettingsView_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess: "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail: "SettingsView_DeleteAccount_Fail"
            case .createAccountPressed: "SettingsView_CreateAccount_Pressed"
            case .contactUsPressed: "SettingsView_ContactUs_Pressed"
            case .ratingPressed: "SettingsView_Rating_Pressed"
            case .ratingYesPressed: "SettingsView_Rating_Yes_Pressed"
            case .ratingNoPressed: "SettingsView_Rating_No_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

private struct RowFormattingViewModifier: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(colorScheme.backgroundPrimary)
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        modifier(RowFormattingViewModifier())
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
