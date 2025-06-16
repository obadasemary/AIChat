//
//  UserManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import Foundation

protocol UserManagerProtocol: Sendable {
    
    @MainActor func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    @MainActor func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
    @MainActor func signOut()
    @MainActor func deleteCurrentUser() async throws
}
