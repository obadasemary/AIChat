//
//  ExploreRouterProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.08.2025.
//

import Foundation

@MainActor
protocol ExploreRouterProtocol {
    func showCategoryListView(delegate: CategoryListDelegate)
    func showChatView(delegate: ChatDelegate)
    func showDevSettingsView()
    func showCreateAccountView(
        delegate: CreateAccountDelegate,
        onDisappear: (() -> Void)?
    )
    func dismissScreen()
    
    func showPushNotificationModal(
        onEnablePressed: @escaping () -> Void,
        onCancelPressed: @escaping () -> Void
    )
    func dismissModal()
    
    func dismissAlert()
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: ExploreRouterProtocol {}
