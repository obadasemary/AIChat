//
//  SettingsRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol SettingsRouterProtocol {
    func showCreateAccountView(
        delegate: CreateAccountDelegate,
        onDisappear: (() -> Void)?
    )
    func showAboutView()
    func showRatingsModal(
        onEnjoyingAppYesPressed: @escaping () -> Void,
        onEnjoyingAppNoPressed: @escaping () -> Void
    )
    func showAlert(
        _ option: RouterAlertType,
        title: String,
        subtitle: String?,
        buttons: (@Sendable () -> AnyView)?
    )
    func showAlert(error: Error)
    func dismissModal()
    func dismissScreen()
}

@MainActor
struct SettingsRouter {
    let router: Router
    let createAccountBuilder: CreateAccountBuilder
    let aboutBuilder: AboutBuilder
}

extension SettingsRouter: SettingsRouterProtocol {
    
    func showCreateAccountView(
        delegate: CreateAccountDelegate,
        onDisappear: (() -> Void)?
    ) {
        router.showScreen(.sheet) { router in
            createAccountBuilder
                .buildCreateAccountView(router: router, delegate: delegate)
                .presentationDetents([.medium])
                .onDisappear {
                    onDisappear?()
                }
        }
    }
    
    func showAboutView() {
        router.showScreen(.push) { router in
            aboutBuilder.buildAboutView(router: router)
        }
    }
    
    func showRatingsModal(
        onEnjoyingAppYesPressed: @escaping () -> Void,
        onEnjoyingAppNoPressed: @escaping () -> Void
    ) {
        router
            .showModal(
                backgroundColor: Color.black.opacity(0.6),
                transition: .fade
            ) {        
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
    }
    
    func showAlert(
        _ option: RouterAlertType,
        title: String,
        subtitle: String?,
        buttons: (@Sendable () -> AnyView)?
    ) {
        router
            .showAlert(
                option,
                title: title,
                subtitle: subtitle,
                buttons: buttons
            )
    }
    
    func showAlert(error: any Error) {
        router
            .showAlert(
                .alert,
                title: "Error",
                subtitle: error.localizedDescription,
                buttons: nil
            )
    }
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    func dismissModal() {
        router.dismissModal()
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: SettingsRouterProtocol {}
