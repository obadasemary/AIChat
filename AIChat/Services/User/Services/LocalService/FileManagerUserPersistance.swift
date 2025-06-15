//
//  FileManagerUserPersistance.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct FileManagerUserPersistance {
    private let userDocumentKey: String = "current_user"
    private let keychain: KeychainHelperProtocol
    
    init(keychain: KeychainHelperProtocol) {
        self.keychain = keychain
    }
}

extension FileManagerUserPersistance: LocalUserServiceProtocol {
    func getCurrentUser() -> UserModel? {
        try? FileManager
            .getDocument(key: userDocumentKey, password: encryptionPassword())
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager
            .saveDocument(
                key: userDocumentKey,
                value: user,
                password: encryptionPassword()
            )
    }
}

private extension FileManagerUserPersistance {
    func encryptionPassword() -> String {
        let keychainKey = "com.myapp.encryptionKey"
        if let existing = try? keychain.get(keychainKey) {
            return existing
        } else {
            let newKey = UUID().uuidString
            try? keychain.set(newKey, for: keychainKey)
            return newKey
        }
    }
}
