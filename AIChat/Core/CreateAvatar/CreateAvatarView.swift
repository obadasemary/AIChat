//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.05.2025.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @State var viewModel: CreateAvatarViewModel
    
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
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                viewModel.onDismissButtonTapped()
            }
            .foregroundStyle(.accent)
    }
    
    var nameSection: some View {
        Section {
            TextField("Avatar name", text: $viewModel.avatarName)
        } header: {
            Text("Name your avatar *")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    var attributesSection: some View {
        Section {
            Picker(selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $viewModel.characterLocation) {
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
                            viewModel.onGenerateImageTapped()
                        }
                        .opacity(viewModel.isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1 : 0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: 400)
            }
            .removeListRowFormatting()
        }
    }
    
    var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: viewModel.isSaving,
                title: "Save",
                action: {
                    viewModel.onSaveTapped()
                }
            )
            .removeListRowFormatting()
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1)
            .disabled(viewModel.generatedImage == nil)
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
