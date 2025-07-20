//
//  RemoteUserServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 13.06.2025.
//

import Foundation

@MainActor
protocol RemoteUserServiceProtocol: Sendable {
    
    func saveUser(user: UserModel) async throws
    
    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    
    func deleteUser(userId: String) async throws
}
