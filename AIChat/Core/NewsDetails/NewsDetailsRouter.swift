//
//  NewsDetailsRouter.swift
//  AIChat
//
//  Created by Claude Code on 13.12.2025.
//

import SwiftUI
import SUIRouting

@MainActor
protocol NewsDetailsRouterProtocol {
    func dismissScreen()
}

@MainActor
struct NewsDetailsRouter {
    let router: Router
}

extension NewsDetailsRouter: NewsDetailsRouterProtocol {
    func dismissScreen() {
        router.dismissScreen()
    }
}
