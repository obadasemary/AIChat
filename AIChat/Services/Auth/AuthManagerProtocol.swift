//
//  AuthManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import Foundation

protocol AuthManagerProtocol: Sendable {
    
    @MainActor func getAuthId() throws -> String
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    
    func linkAppleAccount() async throws -> UserAuthInfo
    
    func linkGoogleAccount() async throws -> UserAuthInfo
    
    @MainActor func signOut() throws
    
    func deleteAccount() async throws
}
