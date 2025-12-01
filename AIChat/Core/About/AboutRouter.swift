//
//  AboutRouter.swift
//  AIChat
//
//  Created by Claude Code on 01.12.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol AboutRouterProtocol {
    // Add navigation methods here if needed in the future
}

@MainActor
struct AboutRouter {
    let router: Router
}

extension AboutRouter: AboutRouterProtocol {
    // Implement navigation methods here if needed
}

//MARK: FIXME We don't need it just if we going to use CoreRouter and CoreBuilder
extension CoreRouter: AboutRouterProtocol {}
