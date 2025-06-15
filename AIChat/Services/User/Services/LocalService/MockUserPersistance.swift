//
//  MockUserPersistance.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

struct MockUserPersistance {
    
    let currentUser: UserModel?
    
    init(currentUser: UserModel? = nil) {
        self.currentUser = currentUser
    }
}

extension MockUserPersistance: LocalUserServiceProtocol {
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {}
}
