//
//  TokenUsageRouter.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import SwiftUI
import SUIRouting

@MainActor
protocol TokenUsageRouterProtocol {
    func showAlert(error: Error)
}

@MainActor
struct TokenUsageRouter {
    let router: Router
}

extension TokenUsageRouter: TokenUsageRouterProtocol {
    func showAlert(error: Error) {
        router.showAlert(
            .alert,
            title: "Token Usage Error",
            subtitle: error.localizedDescription,
            buttons: nil
        )
    }
}

extension CoreRouter: TokenUsageRouterProtocol {}
