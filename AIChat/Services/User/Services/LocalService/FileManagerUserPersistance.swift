//
//  FileManagerUserPersistance.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct FileManagerUserPersistance {
    private let userDocumentKey: String = "current_user"
}

extension FileManagerUserPersistance: LocalUserServiceProtocol {
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
