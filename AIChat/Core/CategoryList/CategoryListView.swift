//
//  CategoryListView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.06.2025.
//

import SwiftUI

struct CategoryListView: View {
    
    @State var viewModel: CategoryListViewModel
    let delegate: CategoryListDelegate
    
    var body: some View {
        List {
            CategoryCellView(
                title: delegate.category.plural.capitalized,
                imageName: delegate.imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if viewModel.isLoading {
                loadingIndicator
            } else if viewModel.avatars.isEmpty {
                contentUnavailableView
            } else {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        viewModel.onAvatarTapped(
                            avatar: avatar,
                            path: delegate.path
                        )
                    }
                    .removeListRowFormatting()
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: Self.screenName)
        .ignoresSafeArea(edges: .top)
        .listStyle(.plain)
        .task {
            await viewModel.loadAvatars(category: delegate.category)
        }
    }
}

// MARK: - SectionViews
private extension CategoryListView {
    
    var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 200)
            .listRowSeparator(.hidden)
            .removeListRowFormatting()
    }
    
    var contentUnavailableView: some View {
        ContentUnavailableView(
            "No Avatars Found",
            systemImage: "bolt.slash",
            description: Text("No Avatars Found For This Category Yet.")
        )
        .listRowSeparator(.hidden)
        .padding(.vertical, 100)
        .removeListRowFormatting()
    }
}

#Preview("Mock Has Data") {
    let container = DevPreview.shared.container
    container.register(
        AvatarManager.self,
        AvatarManager(
            remoteService: MockAvatarService()
        )
    )
    
    let categoryListBuilder = CategoryListBuilder(container: container)
    let delegate = CategoryListDelegate(path: .constant([]))
    
    return categoryListBuilder.buildCategoryListView(delegate: delegate)
        .previewEnvironment()
}

#Preview("Mock No Data") {
    let container = DevPreview.shared.container
    container.register(
        AvatarManager.self,
        AvatarManager(
            remoteService: MockAvatarService(avatars: [])
        )
    )
    
    let categoryListBuilder = CategoryListBuilder(container: container)
    let delegate = CategoryListDelegate(path: .constant([]))
    
    return categoryListBuilder.buildCategoryListView(delegate: delegate)
        .previewEnvironment()
}

#Preview("Mock Slow Loading") {
    let container = DevPreview.shared.container
    container.register(
        AvatarManager.self,
        AvatarManager(
            remoteService: MockAvatarService(delay: 2)
        )
    )
    
    let categoryListBuilder = CategoryListBuilder(container: container)
    let delegate = CategoryListDelegate(path: .constant([]))
    
    return categoryListBuilder.buildCategoryListView(delegate: delegate)
        .previewEnvironment()
}

#Preview("Error Loading") {
    let container = DevPreview.shared.container
    container.register(
        AvatarManager.self,
        AvatarManager(
            remoteService: MockAvatarService(delay: 5, showError: true)
        )
    )
    
    let categoryListBuilder = CategoryListBuilder(container: container)
    let delegate = CategoryListDelegate(path: .constant([]))
    
    return categoryListBuilder.buildCategoryListView(delegate: delegate)
        .previewEnvironment()
}
