//
//  ProfilePresenter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class ProfilePresenter {
    
    private let profileInteractor: ProfileInteractorProtocol
    private let router: ProfileRouterProtocol
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    init(
        profileInteractor: ProfileInteractorProtocol,
        router: ProfileRouterProtocol
    ) {
        self.profileInteractor = profileInteractor
        self.router = router
    }
}

// MARK: - Load
extension ProfilePresenter {
    
    func loadData() async {
        currentUser = profileInteractor.currentUser
        profileInteractor.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            let userId = try profileInteractor.getAuthId()
            myAvatars = try await profileInteractor
                .getAvatarsForAuthor(userId: userId)
            profileInteractor.trackEvent(
                event: Event.loadAvatarsSuccess(
                    count: myAvatars.count
                )
            )
        } catch {
            profileInteractor
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
extension ProfilePresenter {
    
    func onSettingsButtonPressed() {
        profileInteractor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView(
            onSignedIn: { [weak self] in
                Task { [weak self] in
                    guard let self else { return }
                    await self.loadData()
                }
            },
            onDisappear: { [weak self] in
                guard let self else { return }
                self.currentUser = self.profileInteractor.currentUser
                if self.currentUser == nil {
                    self.myAvatars = []
                    self.isLoading = false
                }
            }
        )
    }
    
    func onNewAvatarButtonPressed() {
        profileInteractor.trackEvent(event: Event.newAvatarPressed)
        router.showCreateAvatarView {
            Task { [weak self] in
                guard let self else { return }
                guard self.profileInteractor.currentUser != nil else { return }
                await self.loadData()
            }
        }
    }
    
    func onAvatarSelected(avatar: AvatarModel) {
        profileInteractor
            .trackEvent(
                event: Event.avatarPressed(
                    avatar: avatar
                )
            )
        let delegate = ChatDelegate(avatarId: avatar.avatarId, chat: nil)
        router.showChatView(delegate: delegate)
    }
    
    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        profileInteractor
            .trackEvent(
                event: Event.deleteAvatarStart(
                    avatar: avatar
                )
            )
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.profileInteractor
                    .removeAuthorIdFromAvatar(avatarId: avatar.id)
                if let removalIndex = self.myAvatars
                    .firstIndex(where: { $0.id == avatar.id }) {
                    self.myAvatars.remove(at: removalIndex)
                    self.profileInteractor
                        .trackEvent(
                            event: Event.deleteAvatarSuccess(
                                avatar: avatar
                            )
                        )
                } else {
                    // Avatar not found locally despite server deletion success
                    // This indicates a state inconsistency - log as failure
                    self.profileInteractor
                        .trackEvent(
                            event: Event.deleteAvatarFail(
                                error: NSError(
                                    domain: "ProfilePresenter",
                                    code: -1,
                                    userInfo: [
                                        NSLocalizedDescriptionKey: "Avatar not found in local state after server deletion"
                                    ]
                                )
                            )
                        )
                }
            } catch {
                self.router.showSimpleAlert(
                    title: "Unable to delete avatar",
                    subtitle: "Please try again later."
                )
                self.profileInteractor
                    .trackEvent(
                        event: Event.deleteAvatarFail(
                            error: error
                        )
                    )
            }
        }
    }
    
    func onColorChanged(color: Color) {
        let hexString = color.asHex()
        profileInteractor.trackEvent(event: Event.colorChangeStart(colorHex: hexString))
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.profileInteractor.updateProfileColor(profileColorHex: hexString)
                self.profileInteractor.trackEvent(event: Event.colorChangeSuccess(colorHex: hexString))
            } catch {
                self.router.showSimpleAlert(
                    title: "Unable to update color",
                    subtitle: "Please try again later."
                )
                self.profileInteractor.trackEvent(event: Event.colorChangeFail(error: error))
            }
        }
    }
}

// MARK: - Event
extension ProfilePresenter {
    
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
        case colorChangeStart(colorHex: String)
        case colorChangeSuccess(colorHex: String)
        case colorChangeFail(error: Error)
        
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
            case .colorChangeStart: "ProfileView_ColorChange_Start"
            case .colorChangeSuccess: "ProfileView_ColorChange_Success"
            case .colorChangeFail: "ProfileView_ColorChange_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadAvatarsFail(error: let error), .deleteAvatarFail(error: let error), .colorChangeFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar), .deleteAvatarStart(avatar: let avatar), .deleteAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .colorChangeStart(colorHex: let colorHex), .colorChangeSuccess(colorHex: let colorHex):
                return [
                    "color_hex": colorHex
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail, .colorChangeFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
