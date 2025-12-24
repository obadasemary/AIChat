//
//  ChatsViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 25.07.2025.
//

import Foundation

@Observable
@MainActor
final class ChatsPresenter {
    
    private let chatsInteractor: ChatsInteractorProtocol
    private let router: ChatsRouterProtocol
    
    private(set) var currentUserId: String?
    private(set) var chats: [ChatModel] = []
    private(set) var recentAvatars: [AvatarModel] = []
    private(set) var isLoadingChats: Bool = true
    
    init(
        chatsInteractor: ChatsInteractorProtocol,
        router: ChatsRouterProtocol
    ) {
        self.chatsInteractor = chatsInteractor
        self.router = router
    }
}

// MARK: - Load
extension ChatsPresenter {
    
    func loadRecentAvatars() {
        chatsInteractor.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            recentAvatars = try chatsInteractor.getRecentAvatars()
            chatsInteractor
                .trackEvent(
                    event: Event.loadAvatarsSuccess(
                        avatarCount: recentAvatars.count
                    )
                )
        } catch {
            chatsInteractor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
    }
    
    func loadChats() async {
        chatsInteractor.trackEvent(event: Event.loadChatsStart)
        do {
            let uesrId = try await chatsInteractor.getAuthId()
            currentUserId = uesrId
            chats = try await chatsInteractor
                .getAllChats(userId: uesrId)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            chatsInteractor
                .trackEvent(
                    event: Event.loadChatsSuccess(
                        chatsCount: chats.count
                    )
                )
        } catch {
            chatsInteractor.trackEvent(event: Event.loadChatsFail(error: error))
        }
        isLoadingChats = false
    }
}

// MARK: - Action
extension ChatsPresenter {
    
    func onChatSelected(chat: ChatModel) {
        chatsInteractor.trackEvent(event: Event.chatPressed(chat: chat))
        router.showChatView(
            delegate: ChatDelegate(
                avatarId: chat.avatarId,
                chat: chat
            )
        )
    }
    
    func onRecentsAvatarsTapped(avatar: AvatarModel) {
        chatsInteractor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        router.showChatView(
            delegate: ChatDelegate(
                avatarId: avatar.avatarId,
                chat: nil
            )
        )
    }
}

// MARK: - Event
private extension ChatsPresenter {
    
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
