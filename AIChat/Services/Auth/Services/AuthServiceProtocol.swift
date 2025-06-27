//
//  AuthServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.06.2025.
//

import Foundation

protocol AuthServiceProtocol: Sendable {
    
    func addAuthenticatedUserListener(
        onListenerAttached: (any NSObjectProtocol) -> Void
    ) -> AsyncStream<UserAuthInfo?>
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol)
    
    func getAuthenticatedUser() -> UserAuthInfo?
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signOut() throws
    
    func deleteAccount() async throws
}
