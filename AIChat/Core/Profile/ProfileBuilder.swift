//
//  ProfileBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.08.2025.
//

import SwiftUI

@Observable
@MainActor
final class ProfileBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildProfileView() -> some View {
        ProfileView(
            viewModel: ProfileViewModel(
                profileUseCase: ProfileUseCase(container: container)
            )
        )
    }
}
