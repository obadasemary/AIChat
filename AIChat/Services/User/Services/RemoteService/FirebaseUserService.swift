//
//  FirebaseUserService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 13.06.2025.
//

import Foundation
@preconcurrency import FirebaseFirestore
import SwiftfulFirestore

typealias ListenerRegistration = FirebaseFirestore.ListenerRegistration

struct FirebaseUserService {
    
    private let collectionReference: CollectionReference
    
    init(
        collectionReference: CollectionReference = Firestore.firestore().collection("users")
    ) {
        self.collectionReference = collectionReference
    }
}

extension FirebaseUserService: RemoteUserServiceProtocol {
    
    func saveUser(user: UserModel) async throws {
        try collectionReference
            .document(user.userId)
            .setData(from: user, merge: true)
    }
    
    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws {
        try await collectionReference
            .document(userId)
            .updateData(
                [
                    UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
                    UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
                ]
            )
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collectionReference.streamDocument(id: userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collectionReference.document(userId).delete()
    }
}
