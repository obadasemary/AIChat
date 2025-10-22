//
//  ChatsRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol ChatsRouterProtocol {
    func showChatView(delegate: ChatDelegate)
}

@MainActor
struct ChatsRouter {
    let router: Router
    let chatBuilder: ChatBuilder
}

extension ChatsRouter: ChatsRouterProtocol {
    
    func showChatView(delegate: ChatDelegate) {
        router.showScreen(.push) { router in
            chatBuilder
                .buildChatView(
                    router: router,
                    delegate: delegate
                )
        }
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: ChatsRouterProtocol {}
