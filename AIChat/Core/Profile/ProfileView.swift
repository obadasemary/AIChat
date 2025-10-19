//
//  ProfileView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ProfileView: View {
    
    @State var viewModel: ProfileViewModel
    
    var body: some View {
        List {
            myInfoSection
            myAvatarsSection
        }
        .navigationTitle("Profile")
        .screenAppearAnalytics(name: "ProfileView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - SectionViews
private extension ProfileView {
    
    var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(
                        viewModel.currentUser?.profileColorCalculated ?? .accent
                    )
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
    
    var myAvatarsSection: some View {
        Section {
            if viewModel.myAvatars.isEmpty {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.accent)
                    } else {
                        Text("Click + to create your first avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(viewModel.myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight) {
                        viewModel.onAvatarSelected(avatar: avatar)
                    }
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    viewModel.onDeleteAvatar(indexSet: indexSet)
                }
            }
        } header: {
            HStack(spacing: 0) {
                Text("My avatars")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        viewModel.onNewAvatarButtonPressed()
                    }
            }
        }
    }
    
    var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onSettingsButtonPressed()
            }
    }
}

#Preview() {
    let container = DevPreview.shared.container
    let profileBuilder = ProfileBuilder(container: container)
    
    return RouterView { router in
        profileBuilder.buildProfileView(router: router)
    }
    .previewEnvironment()
}
