//
//  ExploreView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ExploreView: View {
    
    @State var presenter: ExplorePresenter
    
    var body: some View {
        List {
            if presenter.featuredAvatars.isEmpty && presenter.popularAvatars.isEmpty {
                if presenter.isLoadingFeatured || presenter.isLoadingPopular {
                    loadingIndicator
                } else {
                    contentUnavailableView
                }
            }
            
            if !presenter.popularAvatars.isEmpty {
                if presenter.categoryRowTest == .top {
                    categoriesSection
                }
            }
            
            if !presenter.featuredAvatars.isEmpty {
                featuredSection
            }
            
            if !presenter.popularAvatars.isEmpty {
                if presenter.categoryRowTest == .original {
                    categoriesSection
                }
                popularSection
            }
        }
        .navigationTitle("Explore")
        .screenAppearAnalytics(name: "ExploreView")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if presenter.showDevSettingsButton {
                    devSettingsButton
                }
            }
            
            // Notification button
            ToolbarItem(placement: .topBarTrailing) {
                if presenter.showNotificationButton {
                    pushNotificationButton
                }
            }
            
            // Spacer or fallback
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Spacer()
                        .frame(width: .zero)
                }
            }
            
            // Logout button
            ToolbarItem(placement: .topBarTrailing) {
                logoutButton
            }
        }
        .task {
            await presenter.loadFeaturedAvatars()
        }
        .task {
            await presenter.loadPopularAvatars()
        }
        .refreshable {
            await presenter.refreshAvatars()
        }
        .task {
            await presenter.handleShowPushNotificationButton()
        }
        .onFirstAppear {
            presenter.schedulePushNotifications()
            presenter.showCreateAccountScreenIfNeeded()
        }
        .onOpenURL { url in
            presenter.handleDeepLink(url)
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
                CarouselView(items: presenter.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        presenter.onAvaterSelected(avatar: avatar)
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
                        ForEach(presenter.categories, id: \.self) { category in
                            let imageName = presenter.popularAvatars
                                .last(where: { $0.characterOption == category })?
                                .profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    presenter.onCategorySelected(
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
            ForEach(presenter.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    presenter.onAvaterSelected(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    var devSettingsButton: some View {
        Image(systemName: "pencil")
            .font(.headline)
            .padding(4)
            .foregroundStyle(.accent)
            .tappableBackground()
            .anyButton(.press) {
                presenter.onDevSettingsButtonTapped()
            }
    }
    
    var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onPushNotificationButtonTapped()
            }
    }
    
    var logoutButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onLogoutButtonPressed()
            }
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
    
    let exploreBuilder = ExploreBuilder(container: container)
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
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
    
    let exploreBuilder = ExploreBuilder(container: container)
    
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
    .previewEnvironment()
}

#Preview("CategoryRowTest: Original") {
    let container = DevPreview.shared.container
    container
        .register(
            ABTestManager.self,
            ABTestManager(service: MockABTestService(categoryRowTest: .original))
        )
    
    let exploreBuilder = ExploreBuilder(container: container)
    
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
    .previewEnvironment()
}

#Preview("CategoryRowTest: Top") {
    let container = DevPreview.shared.container
    container
        .register(
            ABTestManager.self,
            ABTestManager(service: MockABTestService(categoryRowTest: .top))
        )
    
    let exploreBuilder = ExploreBuilder(container: container)
    
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
    .previewEnvironment()
}

#Preview("CategoryRowTest: Hidden") {
    let container = DevPreview.shared.container
    container
        .register(
            ABTestManager.self,
            ABTestManager(service: MockABTestService(categoryRowTest: .hidden))
        )
    
    let exploreBuilder = ExploreBuilder(container: container)
    
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
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
    
    let exploreBuilder = ExploreBuilder(container: container)
    
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
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
    
    let exploreBuilder = ExploreBuilder(container: container)
    
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
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
    
    let exploreBuilder = ExploreBuilder(container: container)
    
    return RouterView { router in
        exploreBuilder.buildExploreView(router: router)
    }
    .previewEnvironment()
}
