//
//  ChatRowCellViewBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.04.2025.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    
    @State var viewModel: ChatRowCellViewModel
    let delegate: ChatRowCellDelegate
    
    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.isLoading ? "XXXX XXXX XXXX" : viewModel.avatar?.name,
            subheadline: viewModel.subheadline,
            hasNewMessages: viewModel.isLoading ? false : viewModel.hasNewChat
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            await viewModel.loadAvatar(chat: delegate.chat)
        }
        .task {
            await viewModel.loadLastChatMessage(chat: delegate.chat)
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
            viewModel: ChatRowCellViewModel(
                chatRowCellUseCase: AnyChatRowCellUseCase(
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
            viewModel: ChatRowCellViewModel(
                chatRowCellUseCase: AnyChatRowCellUseCase(
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
            viewModel: ChatRowCellViewModel(
                chatRowCellUseCase: AnyChatRowCellUseCase(
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
