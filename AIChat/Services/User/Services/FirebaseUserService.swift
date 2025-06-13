//
//  FirebaseUserService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 13.06.2025.
//


import Foundation
import FirebaseFirestore

struct FirebaseUserService: UserServiceProtocol {
    
    var collectionReference: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collectionReference
            .document(user.userId)
            .setData(from: user, merge: true)
    }
}
