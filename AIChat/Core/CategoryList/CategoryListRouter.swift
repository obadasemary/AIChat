//
//  CategoryListRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 21.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol CategoryListRouterProtocol {
    func showAlert(error: Error)
    func showChatView(delegate: ChatDelegate)
}

@MainActor
struct CategoryListRouter {
    let router: Router
    let chatBuilder: ChatBuilder
}

extension CategoryListRouter: CategoryListRouterProtocol {
    
    func showAlert(error: any Error) {
        router.showAlert(
            .alert,
            title: "Error",
            subtitle: error.localizedDescription,
            buttons: nil
        )
    }
    
    func showChatView(delegate: ChatDelegate) {
        router.showScreen(.push) { router in
            chatBuilder.buildChatView(delegate: delegate)
        }
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: CategoryListRouterProtocol {}
