//
//  CategoryListBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 31.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class CategoryListBuilder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func buildCategoryListView(delegate: CategoryListDelegate) -> some View {
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
