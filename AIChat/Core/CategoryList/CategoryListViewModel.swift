//
//  CategoryListViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.07.2025.
//

import SwiftUI

@Observable
@MainActor
class CategoryListViewModel {
    
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showAlert: AnyAppAlert?
    
    init(container: DependencyContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

// MARK: - Load
extension CategoryListViewModel {
    
    func loadAvatars(category: CharacterOption) async {
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

// MARK: - Action
extension CategoryListViewModel {
    
    func onAvatarTapped(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarTapped(avatar: avatar))
    }
}

// MARK: - Event
extension CategoryListViewModel {
    
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
