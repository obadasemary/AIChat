//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.05.2025.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    
    @State private var isGenerating: Bool = false
    @State private var generatedImage: String?
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
        }
    }
    
    private var dismissButton: some View {
        Image(systemName: "xmark.circle")
            .font(.title)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onDismissButtonTapped()
            }
            .foregroundStyle(.accent)
            .glassedEffect(in: .circle)
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
                                ImageLoaderView(urlString: generatedImage)
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
            try? await Task.sleep(for: .seconds(3))
            generatedImage = Constants.randomImage
            isGenerating = false
        }
    }
    
    private func onSaveTapped() {
        isSaving = true
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            dismiss()
            isSaving = false
        }
    }
}

#Preview {
    CreateAvatarView()
}
