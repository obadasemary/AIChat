//
//  PaywallRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 09.11.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol PaywallRouterProtocol {
    func showAlert(error: Error)
    func showAlert(
        _ option: RouterAlertType,
        title: String,
        subtitle: String?,
        buttons: (@Sendable () -> AnyView)?
    )
    func dismissScreen()
}

@MainActor
struct PaywallRouter {
    let router: Router
}

extension PaywallRouter: PaywallRouterProtocol {

    func showAlert(error: Error) {
        router.showAlert(
            .alert,
            title: "Error",
            subtitle: error.localizedDescription,
            buttons: nil
        )
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

    func dismissScreen() {
        router.dismissScreen()
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: PaywallRouterProtocol {}
