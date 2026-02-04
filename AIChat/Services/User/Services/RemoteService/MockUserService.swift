//
//  MockUserService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 14.06.2025.
//

import Foundation

@MainActor
class MockUserService {
    
    @Published var currentUser: UserModel?
    
    init(currentUser: UserModel? = nil) {
        self.currentUser = currentUser
    }
}

extension MockUserService: RemoteUserServiceProtocol {
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }

    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws {
        guard let currentUser else {
            throw URLError(.unknown)
        }
        
        self.currentUser = UserModel(
            userId: currentUser.userId,
            email: currentUser.email,
            isAnonymous: currentUser.isAnonymous,
            creationDate: currentUser.creationDate,
            creationVersion: currentUser.creationVersion,
            lastSignInDate: currentUser.lastSignInDate,
            didCompleteOnboarding: true,
            profileColorHex: profileColorHex
        )
    }
    
    func updateProfileColor(userId: String, profileColorHex: String) async throws {
        guard let currentUser else {
            throw URLError(.unknown)
        }
        
        self.currentUser = UserModel(
            userId: currentUser.userId,
            email: currentUser.email,
            isAnonymous: currentUser.isAnonymous,
            creationDate: currentUser.creationDate,
            creationVersion: currentUser.creationVersion,
            lastSignInDate: currentUser.lastSignInDate,
            didCompleteOnboarding: currentUser.didCompleteOnboarding,
            profileColorHex: profileColorHex
        )
    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
                
            }
            
            Task {
                for await value in $currentUser.values {
                    if let value {
                        continuation.yield(value)
                    }
                }
            }
        }
    }

    func deleteUser(userId: String) async throws {
        currentUser = nil
    }
}
