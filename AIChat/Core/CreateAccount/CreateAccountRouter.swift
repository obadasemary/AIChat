//
//  CreateAccountRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 25.10.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol CreateAccountRouterProtocol {
    func dismissScreen()
}

@MainActor
struct CreateAccountRouter {
    let router: Router
}

extension CreateAccountRouter: CreateAccountRouterProtocol {
    
    func dismissScreen() {
        router.dismissScreen()
    }
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: CreateAccountRouterProtocol {}
