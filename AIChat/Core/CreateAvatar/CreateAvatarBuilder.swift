//
//  CreateAvatarBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.08.2025.
//

import SwiftUI

@Observable
@MainActor
final class CreateAvatarBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildCreateAvatarView() -> some View {
        CreateAvatarView(
            viewModel: CreateAvatarViewModel(
                createAvatarUseCase: CreateAvatarUseCase(container: container)
            )
        )
    }
}
