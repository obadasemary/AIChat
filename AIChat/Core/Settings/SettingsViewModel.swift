//
//  SettingsViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class SettingsViewModel {
    
    private let settingsUseCase: SettingsUseCaseProtocol
    private let router: SettingsRouterProtocol
    private let onSignedIn: (() -> Void)?
    
    private(set) var isPremium: Bool = false
    private(set) var isAnonymousUser: Bool = true
    private(set) var hasAppleLinked: Bool = false
    private(set) var hasGoogleLinked: Bool = false
    
    var alert: AnyAppAlert?
    
    init(
        settingsUseCase: SettingsUseCaseProtocol,
        router: SettingsRouterProtocol,
        onSignedIn: (() -> Void)? = nil
    ) {
        self.settingsUseCase = settingsUseCase
        self.router = router
        self.onSignedIn = onSignedIn
    }
}

// MARK: - Load
extension SettingsViewModel {
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = settingsUseCase.auth?.isAnonymous == true
        hasAppleLinked = settingsUseCase.auth?.hasAppleLinked == true
        hasGoogleLinked = settingsUseCase.auth?.hasGoogleLinked == true
    }
}

// MARK: - Action
extension SettingsViewModel {
    
    func onSignOutPressed() {
        settingsUseCase.trackEvent(event: Event.signOutStart)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try self.settingsUseCase.signOut()
                self.settingsUseCase
                    .trackEvent(
                        event: Event.signOutSuccess
                    )
                
                await self.dismissScreen()
            } catch {
                self.settingsUseCase
                    .trackEvent(
                        event: Event.signOutFail(
                            error: error
                        )
                    )
                self.router.showAlert(error: error)
            }
        }
    }
    
    func onDeleteAccountPressed() {
        settingsUseCase.trackEvent(event: Event.deleteAccountStart)
        router
            .showAlert(
                .alert,
                title: "Delete Account?",
                subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our servers and you will be logged out forever.",
                buttons: {
                    AnyView(
                        Button("Delete Account", role: .destructive) {
                            self.onDeleteAccountConfirmationPressed()
                        }
                    )
                }
            )
    }
    
    func onDeleteAccountConfirmationPressed() {
        settingsUseCase.trackEvent(event: Event.deleteAccountStartConfirm)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.settingsUseCase.deleteAccount()
                
                self.settingsUseCase
                    .trackEvent(
                        event: Event.deleteAccountSuccess
                    )
                
                await self.dismissScreen()
            } catch {
                self.settingsUseCase
                    .trackEvent(
                        event: Event.deleteAccountFail(
                            error: error
                        )
                    )
                self.router.showAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        settingsUseCase
            .trackEvent(
                event: Event.createAccountPressed
            )
        
        var delegate = CreateAccountDelegate()
        delegate.onDidSignIn = { [weak self] _ in
            guard let self else { return }
            self.setAnonymousAccountStatus()
            self.onSignedIn?()
        }
        router.showCreateAccountView(delegate: delegate) { [weak self] in
            self?.setAnonymousAccountStatus()
        }
    }
    
    func onContactUsPressed() {
        settingsUseCase.trackEvent(event: Event.contactUsPressed)
        
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
        settingsUseCase.trackEvent(event: Event.ratingPressed)
        
        func onEnjoyingAppYesPressed() {
            settingsUseCase.trackEvent(event: Event.ratingYesPressed)
            router.dismissModal()
            AppStoreRatingsHelper.requestRatingsReview()
        }
        
        func onEnjoyingAppNoPressed() {
            settingsUseCase.trackEvent(event: Event.ratingNoPressed)
            router.dismissModal()
        }
        
        router
            .showRatingsModal(
                onEnjoyingAppYesPressed: onEnjoyingAppYesPressed,
                onEnjoyingAppNoPressed: onEnjoyingAppNoPressed
            )
    }
    
    func onManagePurchase() {
        isPremium.toggle()
    }
    
    func onAboutPressed() {
        settingsUseCase.trackEvent(event: Event.aboutPressed)
        router.showAboutView()
    }

    func onAdminPressed() {
        settingsUseCase.trackEvent(event: Event.adminPressed)
        router.showAdminView()
    }

    func onNewsFeedPressed() {
        settingsUseCase.trackEvent(event: Event.newsFeedPressed)
        router.showNewsFeedView()
    }

    func onBookmarksPressed() {
        settingsUseCase.trackEvent(event: Event.bookmarksPressed)
        router.showBookmarksView()
    }
    
    func onLinkAppleAccountPressed() {
        settingsUseCase.trackEvent(event: Event.linkAppleStart)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await self.settingsUseCase.linkAppleAccount()
                self.settingsUseCase.trackEvent(event: Event.linkAppleSuccess(user: user))
                self.setAnonymousAccountStatus()
                self.alert = AnyAppAlert(
                    title: "Account Linked",
                    subtitle: "Your Apple account has been successfully linked. You can now sign in with Apple."
                )
            } catch {
                self.settingsUseCase.trackEvent(event: Event.linkAppleFail(error: error))
                self.alert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onLinkGoogleAccountPressed() {
        settingsUseCase.trackEvent(event: Event.linkGoogleStart)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await self.settingsUseCase.linkGoogleAccount()
                self.settingsUseCase.trackEvent(event: Event.linkGoogleSuccess(user: user))
                self.setAnonymousAccountStatus()
                self.alert = AnyAppAlert(
                    title: "Account Linked",
                    subtitle: "Your Google account has been successfully linked. You can now sign in with Google."
                )
            } catch {
                self.settingsUseCase.trackEvent(event: Event.linkGoogleFail(error: error))
                self.alert = AnyAppAlert(error: error)
            }
        }
    }
}

// MARK: - Helper
private extension SettingsViewModel {
    
    func dismissScreen() async {
        router.dismissScreen()
        try? await Task.sleep(for: .seconds(1))
        settingsUseCase.updateAppState(showTabBarView: false)
    }
}

// MARK: - Event
private extension SettingsViewModel {
    
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
        case aboutPressed
        case adminPressed
        case newsFeedPressed
        case bookmarksPressed
        case linkAppleStart
        case linkAppleSuccess(user: UserAuthInfo)
        case linkAppleFail(error: Error)
        case linkGoogleStart
        case linkGoogleSuccess(user: UserAuthInfo)
        case linkGoogleFail(error: Error)

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
            case .aboutPressed: "SettingsView_About_Pressed"
            case .adminPressed: "SettingsView_Admin_Pressed"
            case .newsFeedPressed: "SettingsView_NewsFeed_Pressed"
            case .bookmarksPressed: "SettingsView_Bookmarks_Pressed"
            case .linkAppleStart: "SettingsView_LinkApple_Start"
            case .linkAppleSuccess: "SettingsView_LinkApple_Success"
            case .linkAppleFail: "SettingsView_LinkApple_Fail"
            case .linkGoogleStart: "SettingsView_LinkGoogle_Start"
            case .linkGoogleSuccess: "SettingsView_LinkGoogle_Success"
            case .linkGoogleFail: "SettingsView_LinkGoogle_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error),
                    .linkAppleFail(error: let error), .linkGoogleFail(error: let error):
                return error.eventParameters
            case .linkAppleSuccess(user: let user), .linkGoogleSuccess(user: let user):
                return user.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail, .linkAppleFail, .linkGoogleFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
