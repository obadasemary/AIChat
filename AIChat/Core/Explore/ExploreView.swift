//
//  ExploreView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    
    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = false
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
            return true
        #else
            return false
        #endif
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    if isLoadingFeatured || isLoadingPopular {
                        loadingIndicator
                    } else {
                        contentUnavailableView
                    }
                }
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                if !popularAvatars.isEmpty {
                    categoriesSection
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
            }
            .sheet(isPresented: $showDevSettings) {
                DevSettingsView()
            }
            .navigationDestinationForCoreModule(path: $path)
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
            .refreshable {
                await refreshAvatars()
            }
        }
    }
    
    private func loadFeaturedAvatars(force: Bool = false) async {
        guard featuredAvatars.isEmpty || force else { return }
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
            print("Error loading featured avatars: \(error)")
        }
        
        isLoadingFeatured = false
    }
    
    private func loadPopularAvatars(force: Bool = false) async {
        guard popularAvatars.isEmpty || force else {
            return
        }
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
            print("Error loading featured avatars: \(error)")
        }
        
        isLoadingPopular = false
    }
    
    private func refreshAvatars() async {
        async let featuredAvatars: () = loadFeaturedAvatars(force: true)
        async let popularAvatars: () = loadPopularAvatars(force: true)
        _ = await (featuredAvatars, popularAvatars)
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 200)
            .removeListRowFormatting()
    }
    
    private var contentUnavailableView: some View {
        ContentUnavailableView(
            "No Connection",
            systemImage: "wifi.slash",
            description: Text("Please check your internet connection and try again later.")
        )
        .padding(.vertical, 200)
        .removeListRowFormatting()
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvaterSelected(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured Avatars")
        }
    }
    
    private var categoriesSection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars
                                .last(where: { $0.characterOption == category })?
                                .profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    onCategorySelected(
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
    
    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    onAvaterSelected(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    private var devSettingsButton: some View {
        HStack {
            Image(systemName:"rectangle.portrait.and.arrow.forward")
            Text("Dev 🤫")
        }
        .badgeButton()
        .anyButton(.press) {
            onDevSettingsButtonTapped()
        }
    }
    
    private func onDevSettingsButtonTapped() {
        showDevSettings = true
    }
    
    private func onAvaterSelected(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    private func onCategorySelected(
        category: CharacterOption,
        imageName: String
    ) {
        path
            .append(
                .character(
                    category: category,
                    imageName: imageName
                )
            )
    }
}

#Preview("Mock Has Data") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: MockAvatarService()
            )
        )
//        .previewEnvironment()
}

#Preview("Mock No Data") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(avatars: [])
            )
        )
//        .previewEnvironment()
}

#Preview("Mock Slow Loading") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(delay: 2)
            )
        )
//        .previewEnvironment()
}

#Preview("Remote Service") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: FirebaseAvatarService(
                    firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
                )
            )
        )
//        .previewEnvironment()
}
