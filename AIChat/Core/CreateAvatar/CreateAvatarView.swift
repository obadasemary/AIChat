//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.05.2025.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var showAlert: AnyAppAlert?
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                avatarImageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    dismissButton
                }
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "CreateAvatar")
        }
    }
}

// MARK: - SectionViews
private extension CreateAvatarView {
    
    var dismissButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onDismissButtonTapped()
            }
            .foregroundStyle(.accent)
    }
    
    var nameSection: some View {
        Section {
            TextField("Avatar name", text: $avatarName)
        } header: {
            Text("Name your avatar *")
        }
    }
    
    var attributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
        }
    }
    
    var avatarImageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton(.plain) {
                            onGenerateImageTapped()
                        }
                        .opacity(isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenerating ? 1 : 0)
                }
                .disabled(isGenerating || avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
            }
            .removeListRowFormatting()
        }
    }
    
    var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: isSaving,
                title: "Save",
                action: onSaveTapped
            )
            .removeListRowFormatting()
            .opacity(generatedImage == nil ? 0.5 : 1)
            .disabled(generatedImage == nil)
        }
    }
}

// MARK: - Action
private extension CreateAvatarView {
    
    func onDismissButtonTapped() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
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
    
    func onSaveTapped() {
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
                
                dismiss()
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
private extension CreateAvatarView {
    
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

#Preview {
    CreateAvatarView()
        .previewEnvironment()
}
