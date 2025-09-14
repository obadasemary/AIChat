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
    func showCreateAvatarView()
    func showSettingsView()
}


@MainActor
struct ProfileRouter {
    let router: Router
    let settingsBuilder: SettingsBuilder
    let createAvatarBuilder: CreateAvatarBuilder
}
    
extension ProfileRouter: ProfileRouterProtocol {
    
    func showCreateAvatarView() {
        router.showScreen(.fullScreenCover) { router in
            createAvatarBuilder.buildCreateAvatarView(router: router)
        }
    }
    
    func showSettingsView() {
        router.showScreen(.sheet) { router in
            settingsBuilder.buildSettingsView()
        }
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: ProfileRouterProtocol {}
