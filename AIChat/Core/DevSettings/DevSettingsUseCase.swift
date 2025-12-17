//
//  DevSettingsUseCase.swift
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

@MainActor
final class DevSettingsUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let abTestManager: ABTestManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            fatalError("Failed to resolve AuthManager for DevSettingsUseCase")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            fatalError("Failed to resolve UserManager for DevSettingsUseCase")
        }
        guard let abTestManager = container.resolve(ABTestManager.self) else {
            fatalError("Failed to resolve ABTestManager for DevSettingsUseCase")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.abTestManager = abTestManager
    }
}

extension DevSettingsUseCase: DevSettingsUseCaseProtocol {
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
    
    func override(updateTests: ActiveABTests) throws {
        try abTestManager.override(updateTests: updateTests)
    }
}
