//
//  ProfileViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    
    private let interactor: ProfileInteractor
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showSettingsView: Bool = false
    var showCreateAvatarView: Bool = false
    var showAlert: AnyAppAlert?
    var path: [NavigationPathOption] = []
    
    init(interactor: ProfileInteractor) {
        self.interactor = interactor
    }
}

// MARK: - Load
extension ProfileViewModel {
    
    func loadData() async {
        currentUser = interactor.currentUser
        interactor.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            let userId = try interactor.getAuthId()
            myAvatars = try await interactor
                .getAvatarsForAuthor(userId: userId)
            interactor.trackEvent(
                event: Event.loadAvatarsSuccess(
                    count: myAvatars.count
                )
            )
        } catch {
            interactor
                .trackEvent(
                    event: Event.loadAvatarsFail(
                        error: error
                    )
                )
        }
        
        isLoading = false
    }
}

// MARK: - Action
extension ProfileViewModel {
    
    func onSettingsButtonPressed() {
        showSettingsView = true
        interactor.trackEvent(event: Event.settingsPressed)
    }
    
    func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
        interactor.trackEvent(event: Event.newAvatarPressed)
    }
    
    func onAvatarSelected(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor
            .trackEvent(
                event: Event.avatarPressed(
                    avatar: avatar
                )
            )
    }
    
    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        interactor
            .trackEvent(
                event: Event.deleteAvatarStart(
                    avatar: avatar
                )
            )
        
        Task {
            do {
                try await interactor
                    .removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
                interactor
                    .trackEvent(
                        event: Event.deleteAvatarSuccess(
                            avatar: avatar
                        )
                    )
            } catch {
                showAlert = AnyAppAlert(
                    title: "Unable to delete avatar",
                    subtitle: "Please try again later."
                )
                interactor
                    .trackEvent(
                        event: Event.deleteAvatarFail(
                            error: error
                        )
                    )
            }
        }
    }
}

// MARK: - Event
extension ProfileViewModel {
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess(count: Int)
        case loadAvatarsFail(error: Error)
        case settingsPressed
        case newAvatarPressed
        case avatarPressed(avatar: AvatarModel)
        case deleteAvatarStart(avatar: AvatarModel)
        case deleteAvatarSuccess(avatar: AvatarModel)
        case deleteAvatarFail(error: Error)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart: "ProfileView_LoadAvatars_Start"
            case .loadAvatarsSuccess: "ProfileView_LoadAvatars_Success"
            case .loadAvatarsFail: "ProfileView_LoadAvatars_Fail"
            case .settingsPressed: "ProfileView_Settings_Pressed"
            case .newAvatarPressed: "ProfileView_NewAvatar_Pressed"
            case .avatarPressed: "ProfileView_Avatar_Pressed"
            case .deleteAvatarStart: "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess: "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail: "ProfileView_DeleteAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadAvatarsFail(error: let error), .deleteAvatarFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar), .deleteAvatarStart(avatar: let avatar), .deleteAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
