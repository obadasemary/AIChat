//
//  CreateAvatarViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import SwiftUI

@Observable
@MainActor
class CreateAvatarViewModel {
    
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    private(set) var isGenerating: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var isSaving: Bool = false
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    
    var avatarName: String = ""
    var showAlert: AnyAppAlert?
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

// MARK: - Action
extension CreateAvatarViewModel {
    
    func onDismissButtonTapped(onDismiss: @escaping () -> Void) {
        logManager.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    // swiftlint:disable force_unwrapping
    func onGenerateImageTapped() {
        isGenerating = true
        logManager.trackEvent(event: Event.generateImageStart)
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                
                let (data, _) = try await URLSession.shared.data(from: URL(string: Constants.randomImage)!)
                if let image = UIImage(data: data) {
                    // Use `image` on the main thread
                    await MainActor.run {
                        self.generatedImage = image
                    }
                }
//                generatedImage = try await aiManager.generateImage(input: prompt.characterDescription)
                logManager
                    .trackEvent(
                        event: Event.generateImageSuccess(
                            avatarDescriptionBuilder: avatarDescriptionBuilder
                        )
                    )
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            isGenerating = false
        }
    }
    // swiftlint:enable force_unwrapping
    
    func onSaveTapped(onDismiss: @escaping () -> Void) {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        isSaving = true
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName)
                let userId = try authManager.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: userId
                )
                
                try await avatarManager
                    .createAvatar(avatar: avatar, image: generatedImage)
                logManager
                    .trackEvent(
                        event: Event.saveAvatarSuccess(
                            avatar: avatar
                        )
                    )
                
                onDismiss()
                isSaving = false
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager
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
extension CreateAvatarViewModel {
    
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
