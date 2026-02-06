//
//  AdminRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SUIRouting

@MainActor
protocol AdminRouterProtocol {
    func showAlert(
        _ option: RouterAlertType,
        title: String,
        subtitle: String?,
        buttons: (@Sendable () -> AnyView)?
    )
    func showAlert(error: Error)
    func dismissScreen()
}

@MainActor
struct AdminRouter {
    let router: Router
}

extension AdminRouter: AdminRouterProtocol {

    func showAlert(
        _ option: RouterAlertType = .alert,
        title: String,
        subtitle: String? = nil,
        buttons: (@Sendable () -> AnyView)? = nil
    ) {
        router.showAlert(option, title: title, subtitle: subtitle, buttons: buttons)
    }

    func showAlert(error: Error) {
        router.showAlert(
            .alert,
            title: "Error",
            subtitle: error.localizedDescription,
            buttons: nil
        )
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}
