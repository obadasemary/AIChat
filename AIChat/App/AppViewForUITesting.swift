//
//  AppViewForUITesting.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import SwiftUI

struct AppViewForUITesting: View {
    
    @Environment(DependencyContainer.self) private var container
    
    private var startOnCreateAvatar: Bool {
        ProcessInfo
            .processInfo
            .arguments
            .contains("STARTSCREEN_CREATE_AVATAR_TEST")
    }
    
    var body: some View {
        if startOnCreateAvatar {
            CreateAvatarView(
                viewModel: CreateAvatarViewModel(
                    createAvatarUseCase: CreateAvatarUseCase(container: DevPreview.shared.container)
                )
            )
        } else {
            AppView(
                viewModel: AppViewModel(
                    appViewUseCase: AppViewUseCase(container: container)
                )
            )
        }
    }
}
