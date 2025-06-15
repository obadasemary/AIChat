//
//  LocalUserServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation

protocol LocalUserServiceProtocol {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
