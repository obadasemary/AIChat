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

extension FirebaseAvatarService: RemoteAvatarServiceProtocol {
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        let path = "avatars/\(avatar.avatarId)"
        let url = try await firebaseImageUploadServiceProtocol.uploadImage(image: image, path: path)
        
        var avatar = avatar
        avatar.updateProfileImage(imageName: url.absoluteString)
        
        try await saveUser(avatar: avatar)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel? {
        try await collectionReference.getDocument(id: id)
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
            .order(
                by: AvatarModel.CodingKeys.clickCount.rawValue,
                descending: true
            )
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
            .order(
                by: AvatarModel.CodingKeys.dateCreated.rawValue,
                descending: true
            )
            .getAllDocuments()
//            .sorted(by: { ($0.dateCreated ?? .distantPast) > ($1.dateCreated ?? .distantPast) })
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collectionReference
            .document(avatarId)
            .updateData([
                AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
            ])
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await collectionReference
            .document(avatarId)
            .updateData([AvatarModel.CodingKeys.authorId.rawValue: NSNull()])
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        let avatars = try await getAvatarsForAuthor(userId: userId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for avatar in avatars {
                group.addTask {
                    try await removeAuthorIdFromAvatar(avatarId: avatar.avatarId)
                }
            }
            
            try await group.waitForAll()
        }
    }
}

private extension FirebaseAvatarService {
    func saveUser(avatar: AvatarModel) async throws {
        try collectionReference
            .document(avatar.avatarId)
            .setData(from: avatar, merge: true)
    }
}
