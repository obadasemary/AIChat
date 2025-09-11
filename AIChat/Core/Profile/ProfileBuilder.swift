//
//  ProfileBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class ProfileBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildProfileView(router: Router) -> some View {
        ProfileView(
            viewModel: ProfileViewModel(
                profileUseCase: ProfileUseCase(container: container),
                router: ProfileRouter(
                    router: router,
                    settingsBuilder: SettingsBuilder(container: container),
                    createAvatarBuilder: CreateAvatarBuilder(
                        container: container
                    )
                )
            )
        )
    }
}
