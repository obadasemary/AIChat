//
//  ProfileView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .navigationDestinationForCoreModule(path: $viewModel.path)
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "ProfileView")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            SettingsView(
                viewModel: SettingsViewModel(
                    settingsUseCase: SettingsUseCase(container: container)
                )
            )
        }
        .fullScreenCover(isPresented: $viewModel.showCreateAvatarView) {
            Task {
                await viewModel.loadData()
            }
        } content: {
            CreateAvatarView(
                viewModel: CreateAvatarViewModel(
                    createAvatarUseCase: CreateAvatarUseCase(
                        container: container
                    )
                )
            )
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

#Preview("CoreInteractor") {
    ProfileView(
        viewModel: ProfileViewModel(
            interactor: CoreInteractor(container: DevPreview.shared.container)
        )
    )
    .previewEnvironment()
}

#Preview("ProdProfileInteractor") {
    ProfileView(
        viewModel: ProfileViewModel(
            interactor: ProdProfileInteractor(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}
