//
//  CategoryListView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.06.2025.
//

import SwiftUI

struct CategoryListView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
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
        .scrollBounceBehavior(.basedOnSize)
        .showCustomAlert(alert: $showAlert)
        .screenAppearAnalytics(name: Self.screenName)
        .ignoresSafeArea(edges: .top)
        .listStyle(.plain)
        .task {
            await loadAvatars()
        }
    }
}

// MARK: - Load
private extension CategoryListView {
    
    func loadAvatars() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await avatarManager
                .getAvatarsForCategory(category: category)
            logManager
                .trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            logManager
                .trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
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

// MARK: - Action
private extension CategoryListView {
    
    func onAvatarTapped(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarTapped(avatar: avatar))
    }
}

// MARK: - Event
private extension CategoryListView {
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarTapped(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarsSuccess: "CategoryList_LoadAvatars_Start"
            case .loadAvatarsStart: "CategoryList_LoadAvatars_Success"
            case .loadAvatarsFail: "CategoryList_LoadAvatars_Fail"
            case .avatarTapped: "CategoryList_Avatar_Tapped"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .loadAvatarsFail(error: let error):
                error.eventParameters
            case .avatarTapped(avatar: let avatar):
                avatar.eventParameters
            default:
                nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail:
                    .severe
            default:
                    .analytic
            }
        }
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
        .previewEnvironment()
}

#Preview("Mock Has Data") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService()
            )
        )
        .previewEnvironment()
}

#Preview("Mock No Data") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(avatars: [])
            )
        )
        .previewEnvironment()
}

#Preview("Mock Slow Loading") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(delay: 2)
            )
        )
        .previewEnvironment()
}

#Preview("Error Loading") {
    CategoryListView(path: .constant([]))
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(delay: 5, showError: true)
            )
        )
        .previewEnvironment()
}
