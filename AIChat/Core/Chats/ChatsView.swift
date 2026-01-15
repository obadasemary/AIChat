//
//  ChatsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ChatsView: View {
    
    @State var presenter: ChatsPresenter
    @Environment(ChatRowCellBuilder.self) private var chatRowCellBuilder
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        List {
            if !presenter.recentAvatars.isEmpty {
                recentsSection
            }
            chatsSection
        }
        .navigationTitle("Chats")
        .screenAppearAnalytics(name: "ChatsView")
        .onAppear {
            presenter.loadRecentAvatars()
        }
        .task {
            await presenter.loadChats()
        }
        .refreshable {
            await presenter.loadChats()
        }
    }
}

// MARK: - SectionViews
private extension ChatsView {
    
    private var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 200)
            .listRowSeparator(.hidden)
            .removeListRowFormatting()
    }
    
    var contentUnavailableView: some View {
        ContentUnavailableView(
            "No Chats Yet",
            systemImage: "\(colorScheme == .dark ? "ellipsis.message.fill" : "ellipsis.message")",
            description: Text("Your chats will appear here...")
        )
        .listRowSeparator(.hidden)
        .padding(.vertical, 100)
        .removeListRowFormatting()
    }
    
    var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(presenter.recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(minHeight: 60)
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .anyButton {
                                presenter
                                    .onRecentsAvatarsTapped(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
        
    }
    
    var chatsSection: some View {
        Section {
            if presenter.isLoadingChats {
                loadingIndicator
            } else if presenter.chats.isEmpty {
                contentUnavailableView
            } else {
                ForEach(presenter.chats) { chat in
                    chatRowCellBuilder
                        .buildChatRowCellBuilderView(
                            delegate: ChatRowCellDelegate(chat: chat)
                        )
                        .anyButton(.highlight) {
                            presenter.onChatSelected(chat: chat)
                        }
                        .removeListRowFormatting()
                }
            }
        } header: {
            Text(presenter.chats.isEmpty ? "" : "CHATS")
        }
    }
}

#Preview("Has Data") {
    let container = DevPreview.shared.container
    
    let chatsBuilder = ChatsBuilder(container: container)
    
    return RouterView { router in
        chatsBuilder.buildChatsView(router: router)
    }
    .previewEnvironment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    
    container.register(AuthManager.self) {
        AuthManager(
            service: MockAuthService(currentUser: .mock(isAnonymous: true))
        )
    }
    container.register(AvatarManager.self) {
        AvatarManager(
            remoteService: MockAvatarService(avatars: []),
            localStorage: MockLocalAvatarServicePersistence(avatars: [])
        )
    }
    container.register(ChatManager.self) {
        ChatManager(service: MockChatService(chats: []))
    }
    container.register(LogManager.self) {
        LogManager(services: [])
    }
    
    let chatsBuilder = ChatsBuilder(container: container)
    
    return RouterView { router in
        chatsBuilder.buildChatsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Slow loading chats") {
    let container = DevPreview.shared.container
    
    container.register(ChatManager.self) {
        ChatManager(service: MockChatService(delay: 5))
    }
    
    let chatsBuilder = ChatsBuilder(container: container)
    
    return RouterView { router in
        chatsBuilder.buildChatsView(router: router)
    }
    .previewEnvironment()
}
