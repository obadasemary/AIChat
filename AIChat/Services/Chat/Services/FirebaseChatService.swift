//
//  FirebaseChatService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.06.2025.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService {
    
    private let collectionReference: CollectionReference
    
    init(
        collectionReference: CollectionReference = Firestore.firestore().collection("chats")
    ) {
        self.collectionReference = collectionReference
    }
}

extension FirebaseChatService: ChatServiceProtocol {
    
    func createNewChat(chat: ChatModel) async throws {
        try collectionReference
            .document(chat.id)
            .setData(from: chat, merge: true)
    }
}
