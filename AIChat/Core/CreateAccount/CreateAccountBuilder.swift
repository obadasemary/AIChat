//
//  CreateAccountBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class CreateAccountBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildCreateAccountView(
        router: Router,
        delegate: CreateAccountDelegate = CreateAccountDelegate()
    ) -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(
                createAccountUseCase: CreateAccountUseCase(
                    container: container
                ),
                router: CreateAccountRouter(router: router)
            ),
            delegate: delegate
        )
    }
}
