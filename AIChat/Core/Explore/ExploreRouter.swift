//
//  ExploreRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.08.2025.
//

import SwiftUI
import SUIRouting

@MainActor
struct ExploreRouter {
    let router: Router
    let categoryListBuilder: CategoryListBuilder
    let chatBuilder: ChatBuilder
    let devSettingsBuilder: DevSettingsBuilder
    let createAccountBuilder: CreateAccountBuilder
}
    
extension ExploreRouter: ExploreRouterProtocol {
    
    // MARK: Segues
    
    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { router in
            categoryListBuilder.buildCategoryListView(delegate: delegate)
        }
    }
    
    func showChatView(delegate: ChatDelegate) {
        router.showScreen(.push) { router in
            chatBuilder.buildChatView(delegate: delegate)
        }
    }
    
    func showDevSettingsView() {
        router.showScreen(.sheet) { router in
            devSettingsBuilder.buildDevSettingsView()
        }
    }
    
    func showCreateAccountView(delegate: CreateAccountDelegate) {
        router.showScreen(.sheet) { router in
            createAccountBuilder.buildCreateAccountView(delegate: delegate)
                .presentationDetents([.medium])
        }
    }
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    // MARK: Modals
    
    func showPushNotificationModal(
        onEnablePressed: @escaping () -> Void,
        onCancelPressed: @escaping () -> Void
    ) {
        router.showModal(
            backgroundColor: Color.black.opacity(0.6),
            transition: .move(edge: .bottom),
            destination: {
                CustomModalView(
                    title: "Enable Push Notifications?",
                    subtitle: "We'll send you updates about new features and improvements",
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
    
    func dismissModal() {
        router.dismissModal()
    }
    
    // MARK: Alerts
    
    func dismissAlert() {
        router.dismissAlert()
    }
}
