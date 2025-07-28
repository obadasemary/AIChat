//
//  DevSettingsUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol DevSettingsUseCaseProtocol {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var activeTests: ActiveABTests { get }
    func override(updateTests: ActiveABTests) throws
}
