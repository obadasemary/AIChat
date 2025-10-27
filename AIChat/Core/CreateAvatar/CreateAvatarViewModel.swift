//
//  CreateAvatarViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import SwiftUI

@Observable
@MainActor
final class CreateAvatarViewModel {
    
    private let createAvatarUseCase: CreateAvatarUseCaseProtocol
    private let router: CreateAvatarRouterProtocol
    
    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var isSaving: Bool = false
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    
    var avatarName: String = ""
    
    init(
        createAvatarUseCase: CreateAvatarUseCaseProtocol,
        router: CreateAvatarRouterProtocol
    ) {
        self.createAvatarUseCase = createAvatarUseCase
        self.router = router
    }
}

// MARK: - Action
extension CreateAvatarViewModel {
    
    func onDismissButtonTapped() {
        createAvatarUseCase.trackEvent(event: Event.backButtonPressed)
        router.dismissScreen()
    }
    
    // swiftlint:disable force_unwrapping
    func onGenerateImageTapped() {
        isGenerating = true
        createAvatarUseCase.trackEvent(event: Event.generateImageStart)
        Task { [weak self] in
            guard let self else { return }
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: self.characterOption,
                    characterAction: self.characterAction,
                    characterLocation: self.characterLocation
                )
                
                self.generatedImage = try await self.createAvatarUseCase.generateImage()
//                let prompt = avatarDescriptionBuilder.characterDescription
//                generatedImage = try await createAvatarUseCase.generateImage(input: prompt)
                self.createAvatarUseCase
                    .trackEvent(
                        event: Event.generateImageSuccess(
                            avatarDescriptionBuilder: avatarDescriptionBuilder
                        )
                    )
            } catch {
                self.createAvatarUseCase
                    .trackEvent(event: Event.generateImageFail(error: error))
            }
            self.isGenerating = false
        }
    }
    // swiftlint:enable force_unwrapping
    
    func onSaveTapped() {
        createAvatarUseCase.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        isSaving = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try TextValidationHelper.checkIfTextIsValid(text: self.avatarName)
                let userId = try self.createAvatarUseCase.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: self.avatarName,
                    option: self.characterOption,
                    action: self.characterAction,
                    location: self.characterLocation,
                    authorId: userId
                )
                
                try await self.createAvatarUseCase
                    .createAvatar(avatar: avatar, image: generatedImage)
                self.createAvatarUseCase
                    .trackEvent(
                        event: Event.saveAvatarSuccess(
                            avatar: avatar
                        )
                    )
                
                self.isSaving = false
                self.router.dismissScreen()
            } catch {
                self.isSaving = false
                self.router.showAlert(error: error)
                self.createAvatarUseCase
                    .trackEvent(
                        event: Event.saveAvatarFail(
                            error: error
                        )
                    )
            }
        }
    }
}

// MARK: - Event
private extension CreateAvatarViewModel {
    
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)
        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .backButtonPressed: "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart: "CreateAvatarView_GenImage_Start"
            case .generateImageSuccess: "CreateAvatarView_GenImage_Success"
            case .generateImageFail: "CreateAvatarView_GenImage_Fail"
            case .saveAvatarStart: "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess: "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail: "CreateAvatarView_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .generateImageSuccess(avatarDescriptionBuilder: let avatarDescriptionBuilder):
                return avatarDescriptionBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .generateImageFail(error: let error), .saveAvatarFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}
