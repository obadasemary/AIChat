//
//  CategoryListView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.06.2025.
//

import SwiftUI

struct CategoryListView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    @Binding var path: [NavigationPathOption]
    
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    
    @State private var avatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if isLoading {
                loadingIndicator
            } else if avatars.isEmpty {
                contentUnavailableView
            } else {
                ForEach(avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        onAvatarTapped(avatar: avatar)
                    }
                    .removeListRowFormatting()
                }
            }
        }
        .showCustomAlert(alert: $showAlert)
        .ignoresSafeArea()
        .listStyle(.plain)
        .task {
            await loadAvatars()
        }
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 200)
            .listRowSeparator(.hidden)
            .removeListRowFormatting()
    }
    
    private var contentUnavailableView: some View {
        ContentUnavailableView(
            "No Avatars Found",
            systemImage: "bolt.slash",
            description: Text("No Avatars Found For This Category Yet.")
        )
        .listRowSeparator(.hidden)
        .padding(.vertical, 100)
        .removeListRowFormatting()
    }
    
    private func loadAvatars() async {
        do {
            avatars = try await avatarManager
                .getAvatarsForCategory(category: category)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
        
        isLoading = false
    }
    
    private func onAvatarTapped(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview("Remote Service") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: FirebaseAvatarService(
                    firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
                )
            )
        )
}

#Preview("Mock Has Data") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService()
            )
        )
}

#Preview("Mock No Data") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(avatars: [])
            )
        )
}

#Preview("Mock Slow Loading") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(delay: 2)
            )
        )
}

#Preview("Error Loading") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(delay: 5, showError: true)
            )
        )
}
