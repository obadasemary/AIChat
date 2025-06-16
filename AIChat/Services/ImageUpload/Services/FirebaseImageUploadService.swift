//
//  FirebaseImageUploadService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import SwiftUI
import FirebaseStorage

struct FirebaseImageUploadService {}

extension FirebaseImageUploadService : FirebaseImageUploadServiceProtocol {
    
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw FirebaseImageUploadServiceError.dataNotAllowed
        }
        
        _ = try await saveImageToCloudStore(data: data, path: path)
        return try await imageReference(path: path).downloadURL()
    }
}

private extension FirebaseImageUploadService {
    func imageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
    
    func saveImageToCloudStore(data: Data, path: String) async throws -> URL {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let storageMetadata = try await imageReference(path: path)
            .putDataAsync(data, metadata: metadata)
        
        guard let returnPath = storageMetadata.path, let url = URL(string: returnPath) else {
            throw FirebaseImageUploadServiceError.badServerResponse
        }
        
        return url
    }
    
    enum FirebaseImageUploadServiceError: LocalizedError {
        case dataNotAllowed
        case badServerResponse
    }
}
