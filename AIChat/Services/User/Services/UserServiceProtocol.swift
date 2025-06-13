//
//  UserServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 13.06.2025.
//

import Foundation

protocol UserServiceProtocol: Sendable {
    
    func saveUser(user: UserModel) async throws
}
