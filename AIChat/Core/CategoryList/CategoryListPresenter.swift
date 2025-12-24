//
//  CategoryListViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.07.2025.
//

import SwiftUI



@Observable
@MainActor
final class CategoryListPresenter {
    
    private let categoryListInteractor: CategoryListInteractorProtocol
    private let router: CategoryListRouterProtocol
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    init(
        categoryListInteractor: CategoryListInteractorProtocol,
        router: CategoryListRouterProtocol
    ) {
        self.categoryListInteractor = categoryListInteractor
        self.router = router
    }
}

// MARK: - Load
extension CategoryListPresenter {
    
    func loadAvatars(category: CharacterOption) async {
        categoryListInteractor.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await categoryListInteractor
                .getAvatarsForCategory(category: category)
            categoryListInteractor
                .trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            router.showAlert(error: error)
            categoryListInteractor
                .trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
    }
}

// MARK: - Action
extension CategoryListPresenter {
    
    func onAvatarTapped(avatar: AvatarModel) {
        categoryListInteractor.trackEvent(event: Event.avatarTapped(avatar: avatar))
        let delegate = ChatDelegate(avatarId: avatar.avatarId)
        router.showChatView(delegate: delegate)
    }
}

// MARK: - Event
private extension CategoryListPresenter {
    
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
