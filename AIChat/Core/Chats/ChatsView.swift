//
//  ChatsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var chats: [ChatModel] = []
    @State private var isLoadingChats: Bool = true
    @State private var recentsAvatars: [AvatarModel] = []
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentsAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
}

// MARK: - Load
private extension ChatsView {
    
    private func loadRecentAvatars() {
        do {
            recentsAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("Faild to load recents avatars: \(error)")
        }
    }
    
    private func loadChats() async {
        do {
            let uesrId = try authManager.getAuthId()
            chats = try await chatManager
                .getAllChats(userId: uesrId)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
        } catch {
            print("Failed to load chats: \(error)")
        }
        isLoadingChats = false
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
                    ForEach(recentsAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton {
                                onRecentsAvatarsTapped(avatar: avatar)
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
            if isLoadingChats {
                loadingIndicator
            } else if chats.isEmpty {
                contentUnavailableView
//                Text("Your chats will appear here...")
//                    .foregroundStyle(.secondary)
//                    .font(.title3)
//                    .frame(maxWidth: .infinity)
//                    .multilineTextAlignment(.center)
//                    .padding()
//                    .removeListRowFormatting()
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: authManager.auth?.uid,
                        chat: chat
                    ) {
                        try? await avatarManager.getAvatar(id: chat.avatarId)
                    } getLastChatMessage: {
                        try? await chatManager
                            .getLastChatMessage(chatId: chat.id)
                    }
                    .anyButton(.highlight) {
                        onChatSelected(chat: chat)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text(chats.isEmpty ? "" : "CHATS")
        }
    }
}

// MARK: - Action
private extension ChatsView {
    
    func onChatSelected(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
    }
    
    func onRecentsAvatarsTapped(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
}

#Preview("Has Data") {
    ChatsView()
        .previewEnvironment()
}

#Preview("No Data") {
    ChatsView()
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(avatars: []),
                localStorage: MockLocalAvatarServicePersistence(avatars: [])
            )
        )
        .environment(ChatManager(service: MockChatService(chats: [])))
        .previewEnvironment()
}

#Preview("Slow loading chats") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5.0)))
        .previewEnvironment()
}
