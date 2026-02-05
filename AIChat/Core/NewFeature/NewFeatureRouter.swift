//
//  NewFeatureRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SUIRouting

@MainActor
protocol NewFeatureRouterProtocol {
    // Add navigation methods here if needed
}

@MainActor
struct NewFeatureRouter {
    let router: Router
}

extension NewFeatureRouter: NewFeatureRouterProtocol {
    // Implement navigation methods here
}

//MARK: FIXME We don't need it just if we going to use ___VARIABLE_coreName:identifier___Router and ___VARIABLE_coreName:identifier___Builder
extension ___VARIABLE_coreName:identifier___Router: NewFeatureRouterProtocol {}
