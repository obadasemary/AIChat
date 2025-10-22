//
//  ChatRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol ChatRouterProtocol {
    func showProfileModal(
        avatar: AvatarModel,
        onXMarkPressed: @escaping () -> Void
    )
    func showPaywallView()
    func showAlert(error: Error)
    func showAlert(
        _ option: RouterAlertType,
        title: String,
        subtitle: String?,
        buttons: (@Sendable () -> AnyView)?
    )
    func dismissModal()
    func dismissScreen()
}

@MainActor
struct ChatRouter {
    let router: Router
    let paywallBuilder: PaywallBuilder
}

extension ChatRouter: ChatRouterProtocol {
    
    func showProfileModal(
        avatar: AvatarModel,
        onXMarkPressed: @escaping () -> Void
    ) {
        router
            .showModal(
                backgroundColor: Color.black.opacity(0.6),
                transition: .slide
            ) {
                ProfileModalView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterOption?.rawValue.capitalized,
                    headline: avatar.characterDescription
                ) {
                    onXMarkPressed()
                }
                .padding()
            }
    }
    
    func showPaywallView() {
        router.showScreen(.sheet) { router in
            paywallBuilder.buildPaywallView(router: router)
        }
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
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
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func dismissScreen() {
        router.dismissScreen()
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: ChatRouterProtocol {}
