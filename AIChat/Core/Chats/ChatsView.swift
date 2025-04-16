//
//  ChatsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ChatsView: View {
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: nil, // FIXME: Add cuid
                        chat: chat
                    ) {
                        try? await Task.sleep(for: .seconds(1))
                        return .mock
                    } getLastChatMessage: {
                        try? await Task.sleep(for: .seconds(1))
                        return .mock
                    }
                    .anyButton(.highlight) {
                        
                    }
                    .removeListRowFormatting()
                }
            }
            .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatsView()
}
