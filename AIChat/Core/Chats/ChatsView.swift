//
//  ChatsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var recentsAvatars: [AvatarModel] = AvatarModel.mocks
    
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
        }
    }
    
    private func loadRecentAvatars() {
        do {
            recentsAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("Faild to load recents avatars: \(error)")
        }
    }
    
    private var recentsSection: some View {
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
    
    private var chatsSection: some View {
        Section {
            if chats.isEmpty {
                Text("Your chats will appear here...")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
                    .removeListRowFormatting()
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: nil, // FIXME: Add cuid
                        chat: chat
                    ) {
                        try? await Task.sleep(for: .seconds(1))
                        return AvatarModel.mocks.randomElement()!
                    } getLastChatMessage: {
                        try? await Task.sleep(for: .seconds(1))
                        return ChatMessageModel.mocks.randomElement()!
                    }
                    .anyButton(.highlight) {
                        onChatSelected(chat: chat)
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("CHATS")
        }
    }
    
    private func onChatSelected(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
    }
    
    private func onRecentsAvatarsTapped(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview {
    ChatsView()
        .environment(AvatarManager(remoteService: MockAvatarService()))
}
