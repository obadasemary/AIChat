//
//  FileManagerUserPersistence.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct FileManagerUserPersistence {
    private let userDocumentKey: String
    
    init(userDocumentKey: String = "current_user") {
        self.userDocumentKey = userDocumentKey
    }
}

extension FileManagerUserPersistence: LocalUserServiceProtocol {
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
