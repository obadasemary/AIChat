//
//  DevSettingsRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 09.11.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol DevSettingsRouterProtocol {
    func dismissScreen()
}

@MainActor
struct DevSettingsRouter {
    let router: Router
}

extension DevSettingsRouter: DevSettingsRouterProtocol {

    func dismissScreen() {
        router.dismissScreen()
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: DevSettingsRouterProtocol {}
