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
    private(set) var showChatViewCalled = false
    private(set) var showChatViewDelegate: ChatDelegate?
    private(set) var showSimpleAlertCalled = false
    private(set) var showSimpleAlertTitle: String?
    private(set) var showSimpleAlertSubtitle: String?
    private(set) var settingsOnSignedInCallback: (() -> Void)?
    private(set) var settingsOnDisappearCallback: (() -> Void)?
    private(set) var createAvatarOnDisappearCallback: (() -> Void)?

    func showSettingsView(
        onSignedIn: @escaping () -> Void,
        onDisappear: @escaping () -> Void
    ) {
        showSettingsViewCalled = true
        settingsOnSignedInCallback = onSignedIn
        settingsOnDisappearCallback = onDisappear
    }

    func showCreateAvatarView(onDisappear: @escaping () -> Void) {
        showCreateAvatarViewCalled = true
        createAvatarOnDisappearCallback = onDisappear
    }
    
    func showChatView(delegate: ChatDelegate) {
        showChatViewCalled = true
        showChatViewDelegate = delegate
    }
    
    func showSimpleAlert(title: String, subtitle: String?) {
        showSimpleAlertCalled = true
        showSimpleAlertTitle = title
        showSimpleAlertSubtitle = subtitle
    }
}
