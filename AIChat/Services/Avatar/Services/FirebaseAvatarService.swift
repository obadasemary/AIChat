//
//  FirebaseAvatarService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

@MainActor
struct FirebaseAvatarService {
    
    private let firebaseImageUploadServiceProtocol: FirebaseImageUploadServiceProtocol
    private let collectionReference: CollectionReference
    
    init(
        firebaseImageUploadServiceProtocol: FirebaseImageUploadServiceProtocol,
        collectionReference: CollectionReference = Firestore.firestore().collection("avatars")
    ) {
        self.firebaseImageUploadServiceProtocol = firebaseImageUploadServiceProtocol
        self.collectionReference = collectionReference
    }
}

extension FirebaseAvatarService: AvatarServiceProtocol {
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        let path = "avatars/\(avatar.avatarId)"
        let url = try await firebaseImageUploadServiceProtocol.uploadImage(image: image, path: path)
        
        var avatar = avatar
        avatar.updateProfileImage(imageName: url.absoluteString)
        
        try await saveUser(avatar: avatar)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collectionReference
            .limit(to: 50)
            .getAllDocuments()
            .shuffled()
            .first(upTo: 5) ?? []
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await collectionReference
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collectionReference
            .whereField(
                AvatarModel.CodingKeys.characterOption.rawValue,
                isEqualTo: category.rawValue
            )
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await collectionReference
            .whereField(
                AvatarModel.CodingKeys.authorId.rawValue,
                isEqualTo: userId
            )
            .getAllDocuments()
    }
}

private extension FirebaseAvatarService {
    func saveUser(avatar: AvatarModel) async throws {
        try collectionReference
            .document(avatar.avatarId)
            .setData(from: avatar, merge: true)
    }
}
