//
//  MockUserService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.06.2025.
//

import Foundation

struct MockUserService {
    
    let currentUser: UserModel?
    
    init(currentUser: UserModel? = nil) {
        self.currentUser = currentUser
    }
}

extension MockUserService: UserServiceProtocol {
    
    func saveUser(user: UserModel) async throws {}

    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws {}

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
                
            }
        }
    }

    func deleteUser(userId: String) async throws {}
}
