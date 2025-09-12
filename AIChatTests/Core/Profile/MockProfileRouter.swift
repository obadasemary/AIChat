//
//  MockProfileRouter.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.09.2025.
//

import Foundation
@testable import AIChat

@MainActor
final class MockProfileRouter: ProfileRouterProtocol {
    
    private(set) var showSettingsViewCalled = false
    private(set) var showCreateAvatarViewCalled = false

    func showSettingsView() {
        showSettingsViewCalled = true
    }

    func showCreateAvatarView() {
        showCreateAvatarViewCalled = true
    }
}
