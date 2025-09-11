//
//  CoreRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.08.2025.
//

import SUIRouting
import SwiftUI

@MainActor
struct CoreRouter {
    let router: Router
    let builder: CoreBuilder
    
    // MARK: Segues
    
    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { router in
            builder.categoryListView(delegate: delegate)
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
    
    func showCreateAccountView(delegate: CreateAccountDelegate) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(delegate: delegate)
                .presentationDetents([.medium])
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
    
    func dismissAlert() {
        router.dismissAlert()
    }
    
    func showCreateAvatarView() {
        router.showScreen(.fullScreenCover) { router in
            builder.createAvatarView()
        }
    }
    
    func showSettingsView() {
        router.showScreen(.sheet) { router in
            builder.settingsView()
        }
    }
}
