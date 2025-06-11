//
//  File.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.06.2025.
//

import SignInGoogleAsync

// MARK: - Concurrency
// GoogleSignInResult is only a pair of Strings, so we can safely mark it Sendable.
extension GoogleSignInResult: @unchecked @retroactive Sendable {}
