//
//  ProfileRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.09.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol ProfileRouterProtocol {
    func showSettingsView()
    func showCreateAvatarView(onDisappear: @escaping () -> Void)
    func showChatView(delegate: ChatDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

@MainActor
struct ProfileRouter {
    let router: Router
    let settingsBuilder: SettingsBuilder
    let createAvatarBuilder: CreateAvatarBuilder
    let chatBuilder: ChatBuilder
}
    
extension ProfileRouter: ProfileRouterProtocol {
    
    func showSettingsView() {
        router.showScreen(.sheet) { router in
            settingsBuilder.buildSettingsView()
        }
    }
    
    func showCreateAvatarView(onDisappear: @escaping () -> Void) {
        router.showScreen(.fullScreenCover) { router in
            createAvatarBuilder.buildCreateAvatarView(router: router)
                .onDisappear(perform: onDisappear)
        }
    }
    
    func showChatView(delegate: ChatDelegate) {
        router.showScreen(.push) { router in
            chatBuilder
                .buildChatView(
                    router: router,
                    delegate: delegate
                )
        }
    }
    
    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: ProfileRouterProtocol {}
