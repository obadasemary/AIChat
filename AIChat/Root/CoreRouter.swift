//
//  CoreRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.08.2025.
//

import SwiftUI
import SUIRouting

typealias RouterView = SUIRouting.RouterView
typealias RouterAlertType = SUIRouting.AlertType

@MainActor
struct CoreRouter {
    let router: Router
    let builder: CoreBuilder
    
    // MARK: Segues
    
    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { router in
            builder.categoryListView(
                router: router,
                delegate: delegate
            )
        }
    }
    
    func showChatView(delegate: ChatDelegate) {
        router.showScreen(.push) { router in
            builder.chatView(delegate: delegate)
        }
    }
    
    func showDevSettingsView() {
        router.showScreen(.sheet) { router in
            builder.devSettingsView()
        }
    }
    
    func showCreateAccountView(
        delegate: CreateAccountDelegate,
        onDisappear: (() -> Void)?
    ) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(delegate: delegate)
                .presentationDetents([.medium])
                .onDisappear {
                    onDisappear?()
                }
        }
    }
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    // MARK: Modals
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) {
        router.showModal(
            backgroundColor: Color.black.opacity(0.6),
            transition: .move(edge: .bottom),
            destination: {
                CustomModalView(
                    title: "Enable push notifications?",
                    subtitle: "We'll send you reminders and updates!",
                    primaryButtonTitle: "Enable",
                    primaryButtonAction: {
                        onEnablePressed()
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: {
                        onCancelPressed()
                    }
                )
            }
        )
    }
    
    // MARK: Alerts
    
    func showAlert(_ option: RouterAlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, buttons: buttons)
    }
    
    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
    
    func dismissAlert() {
        router.dismissAlert()
    }
    
    // MARK: Profile View
    
    func showCreateAvatarView(onDisappear: @escaping () -> Void) {
        router.showScreen(.fullScreenCover) { router in
            builder.createAvatarView(router: router)
                .onDisappear(perform: onDisappear)
        }
    }
    
    func showSettingsView() {
        router.showScreen(.sheet) { router in
            builder.settingsView()
        }
    }
    
    // MARK: Create Avatar View
    
    // MARK: OnboardingIntro
    
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate) {
        router.showScreen(.push) { router in
            builder
                .onboardingIntroView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCommunityView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingColorView(delegate: OnboardingColorDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingColorView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate) {
        router.showScreen(.push) { router in
            builder
                .onboardingCompletedView(router: router, delegate: delegate)
        }
    }
}
