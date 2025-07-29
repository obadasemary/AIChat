//
//  ExploreView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: ExploreViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.featuredAvatars.isEmpty && viewModel.popularAvatars.isEmpty {
                    if viewModel.isLoadingFeatured || viewModel.isLoadingPopular {
                        loadingIndicator
                    } else {
                        contentUnavailableView
                    }
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categoryRowTest == .top {
                        categoriesSection
                    }
                }
                
                if !viewModel.featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categoryRowTest == .original {
                        categoriesSection
                    }
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.showDevSettingsButton {
                        devSettingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.showNotificationButton {
                        pushNotificationButton
                    }
                }
            }
            .sheet(isPresented: $viewModel.showDevSettings) {
                builder.devSettingsView()
            }
            .sheet(isPresented: $viewModel.showCreateAccountView) {
                builder.createAccountView()
                    .presentationDetents([.medium])
            }
            .navigationDestinationForTabbarModule(path: $viewModel.path)
            .showModal(showModal: $viewModel.showPushNotificationModal) {
                pushNotificationModal
            }
            .task {
                await viewModel.loadFeaturedAvatars()
            }
            .task {
                await viewModel.loadPopularAvatars()
            }
            .refreshable {
                await viewModel.refreshAvatars()
            }
            .task {
                await viewModel.handleShowPushNotificationButton()
            }
            .onFirstAppear {
                viewModel.schedulePushNotifications()
                viewModel.showCreateAccountScreenIfNeeded()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url)
            }
        }
    }
}

// MARK: - SectionViews
private extension ExploreView {
    
    var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 200)
            .removeListRowFormatting()
    }
    
    var contentUnavailableView: some View {
        ContentUnavailableView(
            "No Connection",
            systemImage: "wifi.slash",
            description: Text("Please check your internet connection and try again later.")
        )
        .padding(.vertical, 200)
        .removeListRowFormatting()
    }
    
    var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: viewModel.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        viewModel.onAvaterSelected(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured Avatars")
        }
    }
    
    var categoriesSection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            let imageName = viewModel.popularAvatars
                                .last(where: { $0.characterOption == category })?
                                .profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    viewModel.onCategorySelected(
                                        category: category,
                                        imageName: imageName
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(height: 140)
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    var popularSection: some View {
        Section {
            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    viewModel.onAvaterSelected(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    var devSettingsButton: some View {
        HStack {
            Image(systemName:"rectangle.portrait.and.arrow.forward")
            Text("Dev 🤫")
        }
        .badgeButton()
        .anyButton(.press) {
            viewModel.onDevSettingsButtonTapped()
        }
    }
    
    var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onPushNotificationButtonTapped()
            }
    }
    
    var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Push Notifications?",
            subtitle: "We'll send you updates about new features and improvements",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                viewModel.onEnablePushNotificationTapped()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                viewModel.onCancelPushNotificationTapped()
            }
        )
    }
}

#Preview("Mock Has Data") {
    let container = DevPreview.shared.container
    container
        .register(
            AvatarManager.self,
            AvatarManager(
                remoteService: MockAvatarService()
            )
        )
    
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("Mock Has Data w/ create Acct Test") {
    let container = DevPreview.shared.container
    container
        .register(
            AvatarManager.self,
            AvatarManager(
                remoteService: MockAvatarService()
            )
        )
    container
        .register(
            AuthManager.self,
            AuthManager(
                service: MockAuthService(currentUser: .mock(isAnonymous: true))
            )
        )
    container
        .register(
            ABTestManager.self,
            ABTestManager(service: MockABTestService(createAccountTest: true))
        )
    
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("CategoryRowTest: Original") {
    let container = DevPreview.shared.container
    container
        .register(
            ABTestManager.self,
            ABTestManager(service: MockABTestService(categoryRowTest: .original))
        )
    
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("CategoryRowTest: Top") {
    let container = DevPreview.shared.container
    container
        .register(
            ABTestManager.self,
            ABTestManager(service: MockABTestService(categoryRowTest: .top))
        )
    
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("CategoryRowTest: Hidden") {
    let container = DevPreview.shared.container
    container
        .register(
            ABTestManager.self,
            ABTestManager(service: MockABTestService(categoryRowTest: .hidden))
        )
    
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("Mock No Data") {
    let container = DevPreview.shared.container
    container
        .register(
            AvatarManager.self,
            AvatarManager(
                remoteService: MockAvatarService(avatars: [])
            )
        )
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("Mock Slow Loading") {
    let container = DevPreview.shared.container
    container
        .register(
            AvatarManager.self,
            AvatarManager(
                remoteService: MockAvatarService(delay: 2)
            )
        )
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}

#Preview("Remote Service") {
    let container = DevPreview.shared.container
    container
        .register(
            AvatarManager.self,
            AvatarManager(
                remoteService: FirebaseAvatarService(
                    firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
                )
            )
        )
    let builder = CoreBuilder(container: container)
    
    return builder.exploreView()
        .previewEnvironment()
}
