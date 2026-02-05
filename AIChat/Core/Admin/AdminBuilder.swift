//
//  AdminBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class AdminBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildAdminView(router: Router) -> some View {
        AdminView(
            viewModel: AdminViewModel(
                ___VARIABLE_camelCasedProductName:identifier___UseCase: AdminUseCase(container: container),
                router: AdminRouter(router: router)
            )
        )
    }
}
