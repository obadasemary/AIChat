//
//  UserManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 13.06.2025.
//

import Foundation

protocol UserManagerProtocol: Sendable {
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
}

@MainActor
@Observable
final class UserManager {
    
    private let service: UserServiceProtocol
    private(set) var currentUser: UserModel?
    
    init(service: UserServiceProtocol) {
        self.service = service
        self.currentUser = nil
    }
}

extension UserManager: UserManagerProtocol {
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        
        try await service.saveUser(user: user)
    }
}

private extension UserManager {
    
}
