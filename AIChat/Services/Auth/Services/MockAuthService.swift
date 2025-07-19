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
    
    func signOut() throws {
        currentUser = nil
    }
    
    func deleteAccount() async throws {}
}
