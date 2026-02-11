//
//  CreateAvatarBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.08.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class CreateAvatarBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildCreateAvatarView(router: Router) -> some View {
        CreateAvatarView(
            presenter: CreateAvatarPresenter(
                createAvatarInteractor: CreateAvatarInteractor(container: container),
                router: CreateAvatarRouter(router: router)
            )
        )
    }
}

