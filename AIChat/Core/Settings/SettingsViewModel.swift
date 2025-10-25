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
    
    private(set) var isPremium: Bool = false
    private(set) var isAnonymousUser: Bool = true
    
    init(
        settingsUseCase: SettingsUseCaseProtocol,
        router: SettingsRouterProtocol
    ) {
        self.settingsUseCase = settingsUseCase
        self.router = router
    }
}

// MARK: - Load
extension SettingsViewModel {
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = settingsUseCase.auth?.isAnonymous == true
    }
}

// MARK: - Action
extension SettingsViewModel {
    
    func onSignOutPressed() {
        settingsUseCase.trackEvent(event: Event.signOutStart)
        
        Task {
            do {
                try settingsUseCase.signOut()
                settingsUseCase
                    .trackEvent(
                        event: Event.signOutSuccess
                    )
                
                await dismissScreen()
            } catch {
                settingsUseCase
                    .trackEvent(
                        event: Event.signOutFail(
                            error: error
                        )
                    )
                router.showAlert(error: error)
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
        
        Task {
            do {
                try await settingsUseCase.deleteAccount()
                
                settingsUseCase
                    .trackEvent(
                        event: Event.deleteAccountSuccess
                    )
                
                await dismissScreen()
            } catch {
                settingsUseCase
                    .trackEvent(
                        event: Event.deleteAccountFail(
                            error: error
                        )
                    )
                router.showAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        settingsUseCase
            .trackEvent(
                event: Event.createAccountPressed
            )
        
        let delegate = CreateAccountDelegate()
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
