//
//  MockAuthService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.06.2025.
//

import Foundation

struct MockAuthService {
    
    let currentUser: UserAuthInfo?
    
    init(currentUser: UserAuthInfo? = nil) {
        self.currentUser = currentUser
    }
}

extension MockAuthService: AuthServiceProtocol {
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        currentUser
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: true)
        return (user, true)
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signOut() throws {}
    
    func deleteAccount() async throws {}
}
