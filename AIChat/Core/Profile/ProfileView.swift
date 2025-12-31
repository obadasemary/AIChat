//
//  ProfileView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ProfileView: View {
    
    @State var presenter: ProfilePresenter
    
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
            await presenter.loadData()
        }
        .refreshable {
            await presenter.loadData()
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
                        presenter.currentUser?.profileColorCalculated ?? .accent
                    )
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
    
    var myAvatarsSection: some View {
        Section {
            if presenter.myAvatars.isEmpty {
                Group {
                    if presenter.isLoading {
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
                ForEach(presenter.myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight) {
                        presenter.onAvatarSelected(avatar: avatar)
                    }
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    presenter.onDeleteAvatar(indexSet: indexSet)
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
                        presenter.onNewAvatarButtonPressed()
                    }
            }
        }
    }
    
    var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onSettingsButtonPressed()
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
