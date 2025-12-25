//
//  ChatRowCellViewBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.04.2025.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    
    @State var presenter: ChatRowCellPresenter
    let delegate: ChatRowCellDelegate
    
    var body: some View {
        ChatRowCellView(
            imageName: presenter.avatar?.profileImageName,
            headline: presenter.isLoading ? "XXXX XXXX XXXX" : presenter.avatar?.name,
            subheadline: presenter.subheadline,
            hasNewMessages: presenter.isLoading ? false : presenter.hasNewChat
        )
        .redacted(reason: presenter.isLoading ? .placeholder : [])
        .task {
            await presenter.loadAvatar(chat: delegate.chat)
        }
        .task {
            await presenter.loadLastChatMessage(chat: delegate.chat)
        }
    }
}

#Preview {
    VStack {
        let container = DevPreview.shared.container
        let chatRowCellBuilder = ChatRowCellBuilder(container: container)
        let delegate = ChatRowCellDelegate(chat: .mock)
        
        chatRowCellBuilder
            .buildChatRowCellBuilderView(delegate: delegate)
        
        ChatRowCellViewBuilder(
            presenter: ChatRowCellPresenter(
                chatRowCellInteractor: AnyChatRowCellInteractor(
                    getAvatar: { _ in
                        try? await Task.sleep(for: .seconds(5))
                        return .mock
                    },
                    getLastChatMessage: { _ in
                        try? await Task.sleep(for: .seconds(5))
                        return .mock
                    }
                )
            ),
            delegate: ChatRowCellDelegate()
        )

        ChatRowCellViewBuilder(
            presenter: ChatRowCellPresenter(
                chatRowCellInteractor: AnyChatRowCellInteractor(
                    getAvatar: { _ in
                        return .mock
                    },
                    getLastChatMessage: { _ in
                        return .mock
                    }
                )
            ),
            delegate: ChatRowCellDelegate()
        )

        ChatRowCellViewBuilder(
            presenter: ChatRowCellPresenter(
                chatRowCellInteractor: AnyChatRowCellInteractor(
                    getAvatar: { _ in
                        throw URLError(.badURL)
                    },
                    getLastChatMessage: { _ in
                        throw URLError(.badURL)
                    }
                )
            ),
            delegate: ChatRowCellDelegate()
        )
    }
}
