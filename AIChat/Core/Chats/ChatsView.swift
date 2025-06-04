//
//  ChatsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ChatsView: View {
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: nil, // FIXME: Add cuid
                        chat: chat
                    ) {
                        try? await Task.sleep(for: .seconds(1))
                        return AvatarModel.mocks.randomElement()!
                    } getLastChatMessage: {
                        try? await Task.sleep(for: .seconds(1))
                        return ChatMessageModel.mocks.randomElement()!
                    }
                    .anyButton(.highlight) {
                        onChatSelected(chat: chat)
                    }
                    .removeListRowFormatting()
                }
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
        }
    }
    
    private func onChatSelected(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
    }
}

#Preview {
    ChatsView()
}
