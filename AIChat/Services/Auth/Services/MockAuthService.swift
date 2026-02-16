//
//  MockAuthService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.06.2025.
//

import Foundation

@MainActor
class MockAuthService {
    
    @Published var currentUser: UserAuthInfo?
    
    init(currentUser: UserAuthInfo? = nil) {
        self.currentUser = currentUser
    }
}

extension MockAuthService: AuthServiceProtocol {
    
    func addAuthenticatedUserListener(
        onListenerAttached: (any NSObjectProtocol) -> Void
    ) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
            
            Task {
                for await value in $currentUser.values {
                    continuation.yield(value)
                }
            }
        }
    }
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {}
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        currentUser
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: true)
        currentUser = user
        return (user, true)
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        currentUser = user
        return (user, false)
    }
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        currentUser = user
        return (user, false)
    }
    
    func linkAppleAccount() async throws -> UserAuthInfo {
        guard let existingUser = currentUser else {
            throw MockAuthError.userNotFound
        }
        
        var updatedProviders = existingUser.providerIDs
        if !updatedProviders.contains("apple.com") {
            updatedProviders.append("apple.com")
        }
        
        let user = UserAuthInfo(
            uid: existingUser.uid,
            email: existingUser.email,
            isAnonymous: existingUser.isAnonymous,
            creationDate: existingUser.creationDate,
            lastSignInDate: existingUser.lastSignInDate,
            providerIDs: updatedProviders
        )
        currentUser = user
        return user
    }
    
    func linkGoogleAccount() async throws -> UserAuthInfo {
        guard let existingUser = currentUser else {
            throw MockAuthError.userNotFound
        }
        
        var updatedProviders = existingUser.providerIDs
        if !updatedProviders.contains("google.com") {
            updatedProviders.append("google.com")
        }
        
        let user = UserAuthInfo(
            uid: existingUser.uid,
            email: existingUser.email,
            isAnonymous: existingUser.isAnonymous,
            creationDate: existingUser.creationDate,
            lastSignInDate: existingUser.lastSignInDate,
            providerIDs: updatedProviders
        )
        currentUser = user
        return user
    }
    
    func signOut() throws {
        currentUser = nil
    }
    
    func deleteAccount() async throws {}
    
    enum MockAuthError: LocalizedError {
        case userNotFound
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                "No user is currently signed in."
            }
        }
    }
}
