//
//  UserManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 16.06.2025.
//

import Foundation

@MainActor
protocol UserManagerProtocol: Sendable {
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
    func signOut()
    func deleteCurrentUser() async throws
}
