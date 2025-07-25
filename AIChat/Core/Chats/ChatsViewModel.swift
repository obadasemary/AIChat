//
//  ChatsViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 25.07.2025.
//

import Foundation

@Observable
@MainActor
class ChatsViewModel {
    
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    
    private(set) var currentUserId: String?
    private(set) var chats: [ChatModel] = []
    private(set) var recentAvatars: [AvatarModel] = []
    private(set) var isLoadingChats: Bool = true
    
    var path: [NavigationPathOption] = []
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

// MARK: - Load
extension ChatsViewModel {
    
    func getAuthId() async throws -> String {
        try authManager.getAuthId()
    }
    
    func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadAvatarsSuccess(avatarCount: recentAvatars.count))
        } catch {
            print("Faild to load recents avatars: \(error)")
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        do {
            let uesrId = try authManager.getAuthId()
            currentUserId = uesrId
            chats = try await chatManager
                .getAllChats(userId: uesrId)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            logManager.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
        }
        isLoadingChats = false
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try? await avatarManager.getAvatar(id: id)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try? await chatManager.getLastChatMessage(chatId: chatId)
    }
}

// MARK: - Action
extension ChatsViewModel {
    
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
private extension ChatsViewModel {
    
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
