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
    @Environment(LogManager.self) private var logManager
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var chats: [ChatModel] = []
    @State private var isLoadingChats: Bool = true
    @State private var recentAvatars: [AvatarModel] = []
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .screenAppearAnalytics(name: "ChatsView")
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
        logManager.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadAvatarsSuccess(avatarCount: recentAvatars.count))
        } catch {
            print("Faild to load recents avatars: \(error)")
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    private func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        do {
            let uesrId = try authManager.getAuthId()
            chats = try await chatManager
                .getAllChats(userId: uesrId)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            logManager.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
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
                    ForEach(recentAvatars, id: \.self) { avatar in
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
        logManager.trackEvent(event: Event.chatPressed(chat: chat))
    }
    
    func onRecentsAvatarsTapped(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

// MARK: - Event
private extension ChatsView {
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess(avatarCount: Int)
        case loadAvatarsFail(error: Error)
        case loadChatsStart
        case loadChatsSuccess(chatsCount: Int)
        case loadChatsFail(error: Error)
        case chatPressed(chat: ChatModel)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart: "ChatsView_LoadAvatars_Start"
            case .loadAvatarsSuccess: "ChatsView_LoadAvatars_Success"
            case .loadAvatarsFail: "ChatsView_LoadAvatars_Fail"
            case .loadChatsStart: "ChatsView_LoadChats_Start"
            case .loadChatsSuccess: "ChatsView_LoadChats_Success"
            case .loadChatsFail: "ChatsView_LoadChats_Fail"
            case .chatPressed: "ChatsView_Chat_Pressed"
            case .avatarPressed: "ChatsView_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(avatarCount: let avatarCount):
                return [
                    "avatars_count": avatarCount
                ]
            case .loadChatsSuccess(chatsCount: let chatsCount):
                return [
                    "chats_count": chatsCount
                ]
            case .loadAvatarsFail(error: let error), .loadChatsFail(error: let error):
                return error.eventParameters
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .loadChatsFail:
                return .severe
            default:
                return .analytic
            }
        }
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
