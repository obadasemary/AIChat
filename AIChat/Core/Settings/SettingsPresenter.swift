//
//  SettingsPresenter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class SettingsPresenter {
    
    private let settingsInteractor: SettingsInteractorProtocol
    private let router: SettingsRouterProtocol
    private let onSignedIn: (() -> Void)?
    
    private(set) var isPremium: Bool = false
    private(set) var isAnonymousUser: Bool = true
    
    init(
        settingsInteractor: SettingsInteractorProtocol,
        router: SettingsRouterProtocol,
        onSignedIn: (() -> Void)? = nil
    ) {
        self.settingsInteractor = settingsInteractor
        self.router = router
        self.onSignedIn = onSignedIn
    }
}

// MARK: - Load
extension SettingsPresenter {
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = settingsInteractor.auth?.isAnonymous == true
    }
}

// MARK: - Action
extension SettingsPresenter {
    
    func onSignOutPressed() {
        settingsInteractor.trackEvent(event: Event.signOutStart)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try self.settingsInteractor.signOut()
                self.settingsInteractor
                    .trackEvent(
                        event: Event.signOutSuccess
                    )
                
                await self.dismissScreen()
            } catch {
                self.settingsInteractor
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
        settingsInteractor.trackEvent(event: Event.deleteAccountStart)
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
        settingsInteractor.trackEvent(event: Event.deleteAccountStartConfirm)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.settingsInteractor.deleteAccount()
                
                self.settingsInteractor
                    .trackEvent(
                        event: Event.deleteAccountSuccess
                    )
                
                await self.dismissScreen()
            } catch {
                self.settingsInteractor
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
        settingsInteractor
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
        settingsInteractor.trackEvent(event: Event.contactUsPressed)
        
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
        settingsInteractor.trackEvent(event: Event.ratingPressed)
        
        func onEnjoyingAppYesPressed() {
            settingsInteractor.trackEvent(event: Event.ratingYesPressed)
            router.dismissModal()
            AppStoreRatingsHelper.requestRatingsReview()
        }
        
        func onEnjoyingAppNoPressed() {
            settingsInteractor.trackEvent(event: Event.ratingNoPressed)
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
        settingsInteractor.trackEvent(event: Event.aboutPressed)
        router.showAboutView()
    }

    func onAdminPressed() {
        settingsInteractor.trackEvent(event: Event.adminPressed)
        router.showAdminView()
    }

    func onNewsFeedPressed() {
        settingsInteractor.trackEvent(event: Event.newsFeedPressed)
        router.showNewsFeedView()
    }

    func onBookmarksPressed() {
        settingsInteractor.trackEvent(event: Event.bookmarksPressed)
        router.showBookmarksView()
    }
}

// MARK: - Helper
private extension SettingsPresenter {
    
    func dismissScreen() async {
        router.dismissScreen()
        try? await Task.sleep(for: .seconds(1))
        settingsInteractor.updateAppState(showTabBarView: false)
    }
}

// MARK: - Event
private extension SettingsPresenter {
    
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
