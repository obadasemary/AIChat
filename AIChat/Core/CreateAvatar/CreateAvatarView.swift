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
        }
    }
    
    private var dismissButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onDismissButtonTapped()
            }
            .foregroundStyle(.accent)
    }
    
    private var nameSection: some View {
        Section {
            TextField("Avatar name", text: $avatarName)
        } header: {
            Text("Name your avatar *")
        }
    }
    
    private var attributesSection: some View {
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
    
    private var avatarImageSection: some View {
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
    
    private var saveSection: some View {
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
    
    private func onDismissButtonTapped() {
        dismiss()
    }
    
    private func onGenerateImageTapped() {
        isGenerating = true
        Task {
            do {
                _ = AvatarDescriptionBuilder(
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
            } catch {
                print("Error generating image: \(error)")
            }
            isGenerating = false
        }
    }
    
    private func onSaveTapped() {
        guard let generatedImage else { return }
        isSaving = true
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName)
                let uId = try authManager.getAuthId()
                
                let avatar = AvatarModel(
                    avatarId: UUID().uuidString,
                    name: avatarName,
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation,
                    profileImageName: nil,
                    authorId: uId,
                    dateCreated: .now,
                    clickCount: 0
                )
                
                try await avatarManager
                    .createAvatar(avatar: avatar, image: generatedImage)
                
                dismiss()
                isSaving = false
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIServer()))
        .environment(AvatarManager(remoteService: MockAvatarService()))
        .environment(
            AuthManager(service: MockAuthService(currentUser: .mock()))
        )
}
