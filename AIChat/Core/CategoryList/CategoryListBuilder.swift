//
//  CategoryListBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class CategoryListBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildCategoryListView(
        router: Router,
        delegate: CategoryListDelegate
    ) -> some View {
        CategoryListView(
            presenter: CategoryListPresenter(
                categoryListInteractor: CategoryListInteractor(
                    container: container
                ),
                router: CategoryListRouter(
                    router: router,
                    chatBuilder: ChatBuilder(container: container)
                )
            ),
            delegate: delegate
        )
    }
}
