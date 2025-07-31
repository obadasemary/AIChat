//
//  TabBarBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class TabBarBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildTabBarView() -> some View {
        TabBarView()
    }
}
