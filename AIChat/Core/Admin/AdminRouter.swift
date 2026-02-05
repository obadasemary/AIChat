//
//  AdminRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SUIRouting

@MainActor
protocol AdminRouterProtocol {
    // Add navigation methods here if needed
}

@MainActor
struct AdminRouter {
    let router: Router
}

extension AdminRouter: AdminRouterProtocol {
    // Implement navigation methods here
}

//MARK: FIXME We don't need it just if we going to use ___VARIABLE_coreName:identifier___Router and ___VARIABLE_coreName:identifier___Builder
extension ___VARIABLE_coreName:identifier___Router: AdminRouterProtocol {}
