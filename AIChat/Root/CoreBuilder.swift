//
//  CoreBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI

@Observable
@MainActor
class CoreBuilder {
    
    let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func appView() -> some View {
        AppView(
            viewModel: AppViewModel(
                appViewUseCase: AppViewUseCase(
                    container: container
                )
            )
        )
    }
    
    func tabBarView() -> some View {
        TabBarView()
    }
    
    func welcomeView() -> some View {
        WelcomeView(
            viewModel: WelcomeViewModel(
                welcomeUseCase: WelcomeUseCase(container: container)
            )
        )
    }
    
    func exploreView() -> some View {
        ExploreView(
            viewModel: ExploreViewModel(
                interactor: CoreInteractor(container: container)
            )
        )
    }
    
    func createAccountView(
        delegate: CreateAccountDelegate = CreateAccountDelegate()
    ) -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(
                createAccountUseCase: CreateAccountUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func devSettingsView() -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(
                devSettingsUseCase: DevSettingsUseCase(container: container)
            )
        )
    }
    
    func categoryListView(delegate: CategoryListDelegate) -> some View {
        CategoryListView(
            viewModel: CategoryListViewModel(
                categoryListUseCase: CategoryListUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
}
