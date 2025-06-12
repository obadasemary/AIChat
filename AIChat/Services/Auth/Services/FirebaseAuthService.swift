//
//  FirebaseAuthService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.06.2025.
//

import FirebaseAuth
import SwiftUI
import SignInAppleAsync
import SignInGoogleAsync
import FirebaseCore

struct FirebaseAuthService: AuthService {
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            _ = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
        }
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return UserAuthInfo(user: user)
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = await SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        return try await signIn(with: credential)
    }
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }
        
        let googleHelper = SignInWithGoogleHelper(GIDClientID: clientID)
        let tokens = try await googleHelper.signIn()
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: tokens.idToken,
            accessToken: tokens.accessToken
        )
        
        return try await signIn(with: credential)
    }
    
    private func signIn(
        with credential: AuthCredential
    ) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .credentialAlreadyInUse, .providerAlreadyLinked:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? OAuthCredential {
                        let result = try await Auth.auth().signIn(with: secondaryCredential)
                        return result.asAuthInfo
                    }
                default:
                    break
                }
            }
        }
        
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        try await user.delete()
    }
    
    enum AuthError: LocalizedError {
        case userNotFound
        case missingClientID
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                "Current authenticated User not found."
            case .missingClientID:
                "Firebase Client ID is missing."
            }
        }
    }
}

extension AuthDataResult {
    
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
}
