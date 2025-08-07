//
//  ExploreBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class ExploreBuilder {
    private let container: DependencyContainer
//    private let devSettingsBuilder: DevSettingsBuilder
//    private let createAccountBuilder: CreateAccountBuilder

    init(
        container: DependencyContainer
//        ,
//        devSettingsBuilder: DevSettingsBuilder,
//        createAccountBuilder: CreateAccountBuilder
    ) {
        self.container = container
//        self.devSettingsBuilder = devSettingsBuilder
//        self.createAccountBuilder = createAccountBuilder
    }

    func buildExploreView() -> some View {
        ExploreView(
            viewModel: ExploreViewModel(
                exploreUseCase: ExploreUseCase(container: container)
            )
//            ,
//            devSettingsView: {
//                self.devSettingsBuilder.buildDevSettingsView()
//            },
//            createAccountView: {
//                self.createAccountBuilder.buildCreateAccountView()
//            }
        )
    }
}
