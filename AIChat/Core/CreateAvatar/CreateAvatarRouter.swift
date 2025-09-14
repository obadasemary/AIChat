//
//  CreateAvatarRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.09.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol CreateAvatarRouterProtocol {
    func dismissScreen()
    func showAlert(error: Error)
}

@MainActor
struct CreateAvatarRouter {
    let router: Router
}
    
extension CreateAvatarRouter: CreateAvatarRouterProtocol {
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: CreateAvatarRouterProtocol {}

