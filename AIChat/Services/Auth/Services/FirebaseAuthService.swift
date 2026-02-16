//
//  FirebaseAuthService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 06.06.2025.
//

import Foundation
@preconcurrency import FirebaseAuth
import SignInAppleAsync
import SignInGoogleAsync
import FirebaseCore

struct FirebaseAuthService {}
 
extension FirebaseAuthService: AuthServiceProtocol {
    
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
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
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
        let helper = SignInWithAppleHelper()
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
    
    func linkAppleAccount() async throws -> UserAuthInfo {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        let result = try await user.link(with: credential)
        return UserAuthInfo(user: result.user)
    }
    
    func linkGoogleAccount() async throws -> UserAuthInfo {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }
        
        let googleHelper = SignInWithGoogleHelper(GIDClientID: clientID)
        let tokens = try await googleHelper.signIn()
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: tokens.idToken,
            accessToken: tokens.accessToken
        )
        
        let result = try await user.link(with: credential)
        return UserAuthInfo(user: result.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.delete()
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)
            switch authError {
            case .requiresRecentLogin:
                try await reauthenticateUser(error: error)
                
                return try await user.delete()
            default:
                throw error
            }
        }
    }
}

private extension FirebaseAuthService {
    
    func signIn(
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
        
        do {
            let result = try await Auth.auth().signIn(with: credential)
            return result.asAuthInfo
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)
            switch authError {
            case .accountExistsWithDifferentCredential:
                if let email = error.userInfo["FIRAuthErrorUserInfoEmailKey"] as? String {
                    throw AuthError.accountExistsWithDifferentProvider(email: email)
                }
                throw error
            default:
                throw error
            }
        }
    }
    
    func reauthenticateUser(error: Error) async throws {
        guard let user = Auth.auth().currentUser,
              let providerId = user.providerData.first?.providerID
        else {
            throw AuthError.userNotFound
        }
        
        switch providerId {
        case "apple.com":
            let result = try await signInWithApple()
            
            guard user.uid == result.user.uid else {
                throw AuthError.reauthAccountChanged
            }
        case "google.com":
            let result = try await signInWithGoogle()
            
            guard user.uid == result.user.uid else {
                throw AuthError.reauthAccountChanged
            }
        default:
            throw error
        }
    }
      
    enum AuthError: LocalizedError {
        case userNotFound
        case missingClientID
        case reauthAccountChanged
        case accountExistsWithDifferentProvider(email: String)
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                "Current authenticated User not found."
            case .missingClientID:
                "Firebase Client ID is missing."
            case .reauthAccountChanged:
                "Reauthenticated user has switched accounts. Please check your account."
            case .accountExistsWithDifferentProvider(email: let email):
                "An account with email \(email) already exists with a different sign-in method. Please sign in with your original method and link this account in settings."
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
