//
//  CategoryListViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class CategoryListViewModel {
    
    private let categoryListUseCase: CategoryListUseCaseProtocol
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showAlert: AnyAppAlert?
    
    init(categoryListUseCase: CategoryListUseCaseProtocol) {
        self.categoryListUseCase = categoryListUseCase
    }
}

// MARK: - Load
extension CategoryListViewModel {
    
    func loadAvatars(category: CharacterOption) async {
        categoryListUseCase.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await categoryListUseCase
                .getAvatarsForCategory(category: category)
            categoryListUseCase
                .trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            categoryListUseCase
                .trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
    }
}

// MARK: - Action
extension CategoryListViewModel {
    
    func onAvatarTapped(avatar: AvatarModel, path: Binding<[TabbarPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        categoryListUseCase.trackEvent(event: Event.avatarTapped(avatar: avatar))
    }
}

// MARK: - Event
private extension CategoryListViewModel {
    
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
