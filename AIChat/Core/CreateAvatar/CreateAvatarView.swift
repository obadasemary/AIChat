//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.05.2025.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @State var presenter: CreateAvatarPresenter
    
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
            .screenAppearAnalytics(name: "CreateAvatar")
        }
    }
}

// MARK: - SectionViews
private extension CreateAvatarView {
    
    var dismissButton: some View {
        if #available(iOS 26.0, *) {
            return Button(role: .close) {
                presenter.onDismissButtonTapped()
            }
            .tint(.accent)
        } else {
            // Fallback on earlier versions
            return Image(systemName: "xmark")
                .font(.title2)
                .fontWeight(.semibold)
                .anyButton(.plain) {
                    presenter.onDismissButtonTapped()
                }
                .foregroundStyle(.accent)
        }
    }
    
    var nameSection: some View {
        Section {
            TextField("Avatar name", text: $presenter.avatarName)
        } header: {
            Text("Name your avatar *")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    var attributesSection: some View {
        Section {
            Picker(selection: $presenter.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $presenter.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $presenter.characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    var avatarImageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .anyButton(.plain) {
                            presenter.onGenerateImageTapped()
                        }
                        .opacity(presenter.isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(presenter.isGenerating ? 1 : 0)
                }
                .disabled(presenter.isGenerating || presenter.avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage = presenter.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: 400)
            }
        }
    }
    
    var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: presenter.isSaving,
                title: "Save",
                action: {
                    presenter.onSaveTapped()
                }
            )
            .removeListRowFormatting()
            .opacity(presenter.generatedImage == nil ? 0.5 : 1)
            .disabled(presenter.generatedImage == nil)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let createAvatarBuilder = CreateAvatarBuilder(container: container)
    
    return RouterView { router in
        createAvatarBuilder.buildCreateAvatarView(router: router)
    }
    .previewEnvironment()
}
