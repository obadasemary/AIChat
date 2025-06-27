//
//  AuthManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.06.2025.
//

import Foundation

@MainActor
@Observable
final class AuthManager {
    
    private let service: AuthServiceProtocol
    private let logManager: LogManagerProtocol?
    
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    
    init(
        service: AuthServiceProtocol,
        logManager: LogManagerProtocol? = nil
    ) {
        self.service = service
        self.logManager = logManager
        
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
}

extension AuthManager: AuthManagerProtocol {
    func getAuthId() throws -> String {
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInAnonymously()
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        defer {
            addAuthListener()
        }
        
        return try await service.signInWithApple()
    }
    
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        defer {
            addAuthListener()
        }
        
        return try await service.signInWithGoogle()
    }
    
    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        
        try service.signOut()
        auth = nil
        
        logManager?.trackEvent(event: Event.signOutSuccess)
    }
    
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        try await service.deleteAccount()
        auth = nil
        
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
    }
}

private extension AuthManager {
    private func addAuthListener() {
        logManager?.trackEvent(event: Event.authListenerStart)
        if let listener {
            service.removeAuthenticatedUserListener(listener: listener)
        }
        
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.auth = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                
                if let value {
                    logManager?.identify(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
                }
            }
        }
    }
    
    enum AuthError: LocalizedError {
        case notSignedIn
    }
}

// MARK: - Event
private extension AuthManager {
    
    enum Event: LoggableEvent {
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfo?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess

        var eventName: String {
            switch self {
            case .authListenerStart: "AuthMan_AuthListener_Start"
            case .authListenerSuccess: "AuthMan_AuthListener_Success"
            case .signOutStart: "AuthMan_SignOut_Start"
            case .signOutSuccess: "AuthMan_SignOut_Success"
            case .deleteAccountStart: "AuthMan_DeleteAccount_Start"
            case .deleteAccountSuccess: "AuthMan_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(user: let user):
                return user?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
