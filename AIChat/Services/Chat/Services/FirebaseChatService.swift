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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
//        let result: [ChatModel] = try await collectionReference
//            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(
//                ChatModel.CodingKeys.avatarId.rawValue,
//                isEqualTo: avatarId
//            )
//            .getAllDocuments()
//        
//        return result.first
        
        try await collectionReference
            .getDocument(
                id: ChatModel.chatId(userId: userId, avatarId: avatarId)
            )
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await collectionReference
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    
    func addChatMessage(message: ChatMessageModel) async throws {
        try messageCollectionReference(for: message.chatId)
            .document(message.id)
            .setData(from: message, merge: true)
        
        try await collectionReference
            .document(message.chatId).updateData([
                ChatModel.CodingKeys.dateModified.rawValue: Date.now
            ])
    }
    
    func streamChatMessages(
        chatId: String,
        onListenerConfigured: @escaping (ListenerRegistration) -> Void
    ) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        messageCollectionReference(for: chatId)
            .streamAllDocuments()
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messageCollectionReference(for: chatId)
            .order(
                by: ChatMessageModel.CodingKeys.dateCreated.rawValue,
                descending: true
            )
            .limit(to: 1)
            .getAllDocuments()
        
        return messages.first
    }
}

private extension FirebaseChatService {
    
    func messageCollectionReference(for chatId: String) -> CollectionReference {
        collectionReference.document(chatId).collection("messages")
    }
}
