//
//  AuthServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.06.2025.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var authService: AuthServiceProtocol = MockAuthService()
}

protocol AuthServiceProtocol: Sendable {
    func getAuthenticatedUser() -> UserAuthInfo?
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signOut() throws
    
    func deleteAccount() async throws
}
