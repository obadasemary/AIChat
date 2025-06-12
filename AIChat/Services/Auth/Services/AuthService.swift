//
//  AuthService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.06.2025.
//

import SwiftUI

protocol AuthService: Sendable {
    
    func addAuthenticatedUserListener(
        onListenerAttached: (any NSObjectProtocol) -> Void
    ) -> AsyncStream<UserAuthInfo?>
    
    func getAuthenticatedUser() -> UserAuthInfo?
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signOut() throws
    
    func deleteAccount() async throws
}
