//
//  CreateAccountDelegate.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import Foundation

struct CreateAccountDelegate {
    var title: String = "Create Account"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
}
