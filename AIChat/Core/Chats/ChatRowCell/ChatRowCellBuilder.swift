//
//  ChatRowCellBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import SwiftUI

@Observable
@MainActor
final class ChatRowCellBuilder {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func buildChatRowCellBuilderView(
        delegate: ChatRowCellDelegate = ChatRowCellDelegate()
    ) -> some View {
        ChatRowCellViewBuilder(
            presenter: ChatRowCellPresenter(
                chatRowCellInteractor: ChatRowCellInteractor(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
}
