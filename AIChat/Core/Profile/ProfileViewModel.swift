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
    
    private let profileUseCase: ProfileUseCaseProtocol
    private let router: ProfileRouterProtocol
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    init(
        profileUseCase: ProfileUseCaseProtocol,
        router: ProfileRouterProtocol
    ) {
        self.profileUseCase = profileUseCase
        self.router = router
    }
}

// MARK: - Load
extension ProfileViewModel {
    
    func loadData() async {
        currentUser = profileUseCase.currentUser
        profileUseCase.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            let userId = try profileUseCase.getAuthId()
            myAvatars = try await profileUseCase
                .getAvatarsForAuthor(userId: userId)
            profileUseCase.trackEvent(
                event: Event.loadAvatarsSuccess(
                    count: myAvatars.count
                )
            )
        } catch {
            profileUseCase
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
        profileUseCase.trackEvent(event: Event.settingsPressed)
        router.showSettingsView(
            onSignedIn: { [weak self] in
                Task { [weak self] in
                    guard let self else { return }
                    await self.loadData()
                }
            },
            onDisappear: { [weak self] in
                guard let self else { return }
                self.currentUser = self.profileUseCase.currentUser
                if self.currentUser == nil {
                    self.myAvatars = []
                    self.isLoading = false
                }
            }
        )
    }
    
    func onNewAvatarButtonPressed() {
        profileUseCase.trackEvent(event: Event.newAvatarPressed)
        router.showCreateAvatarView {
            Task { [weak self] in
                guard let self else { return }
                guard self.profileUseCase.currentUser != nil else { return }
                await self.loadData()
            }
        }
    }
    
    func onAvatarSelected(avatar: AvatarModel) {
        profileUseCase
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
        profileUseCase
            .trackEvent(
                event: Event.deleteAvatarStart(
                    avatar: avatar
                )
            )
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.profileUseCase
                    .removeAuthorIdFromAvatar(avatarId: avatar.id)
                if let removalIndex = self.myAvatars
                    .firstIndex(where: { $0.id == avatar.id }) {
                    self.myAvatars.remove(at: removalIndex)
                    self.profileUseCase
                        .trackEvent(
                            event: Event.deleteAvatarSuccess(
                                avatar: avatar
                            )
                        )
                } else {
                    // Avatar not found locally despite server deletion success
                    // This indicates a state inconsistency - log as failure
                    self.profileUseCase
                        .trackEvent(
                            event: Event.deleteAvatarFail(
                                error: NSError(
                                    domain: "ProfileViewModel",
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
                self.profileUseCase
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
