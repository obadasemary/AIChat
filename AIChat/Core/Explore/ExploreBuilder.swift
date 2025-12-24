//
//  ExploreBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class ExploreBuilder {
    private let container: DependencyContainer
    
    init(
        container: DependencyContainer
    ) {
        self.container = container
    }
    
    func buildExploreView(router: Router) -> some View {
        ExploreView(
            presenter: ExplorePresenter(
                exploreInteractor: ExploreInteractor(container: container),
                router: ExploreRouter(
                    router: router,
                    categoryListBuilder: CategoryListBuilder(
                        container: container
                    ),
                    chatBuilder: ChatBuilder(container: container),
                    devSettingsBuilder: DevSettingsBuilder(container: container),
                    createAccountBuilder: CreateAccountBuilder(
                        container: container
                    )
                )
            )
        )
    }
}
