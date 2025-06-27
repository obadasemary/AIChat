//
//  UserManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 13.06.2025.
//

import Foundation

@MainActor
@Observable
final class UserManager {
    
    private let remoteService: RemoteUserServiceProtocol
    private let localStorage: LocalUserServiceProtocol
    private let logManager: LogManagerProtocol?
    
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?
    
    init(
        services: UserServicesProtocol,
        logManager: LogManagerProtocol? = nil
    ) {
        self.remoteService = services.remoteService
        self.localStorage = services.localStorage
        self.logManager = logManager
        
        self.currentUser = localStorage.getCurrentUser()
    }
}

extension UserManager: UserManagerProtocol {
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?
            .trackEvent(
                event: Event.logInStart(
                    user: user
                )
            )
        
        try await remoteService.saveUser(user: user)
        logManager?
            .trackEvent(
                event: Event.logInSuccess(
                    user: user
                )
            )
        
        addCurrentUserListener(userId: auth.uid)
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uId = try currentUserId()
        try await remoteService
            .markOnboardingAsCompleted(
                userId: uId,
                profileColorHex: profileColorHex
            )
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
    }
    
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        let uId = try currentUserId()
        try await remoteService.deleteUser(userId: uId)
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        
        signOut()
    }
}

private extension UserManager {
    
    func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()
        logManager?.trackEvent(event: Event.remoteListenerStart)
        
        Task {
            do {
                for try await value in remoteService.streamUser(userId: userId) {
                    self.currentUser = value
                    logManager?
                        .trackEvent(
                            event: Event.remoteListenerSuccess(
                                user: value
                            )
                        )
                    logManager?
                        .addUserProperties(
                            dict: value.eventParameters,
                            isHighPriority: true
                        )
                        
                    saveCurrentUserLocally()
                }
            } catch {
                logManager?
                    .trackEvent(
                        event: Event.remoteListenerFail(
                            error: error
                        )
                    )
            }
        }
    }
    
    func currentUserId() throws -> String {
        guard let uId = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        
        return uId
    }
    
    func saveCurrentUserLocally() {
        logManager?
            .trackEvent(
                event: Event.saveLocalStart(
                    user: currentUser
                )
            )
        
        Task {
            do {
                try localStorage.saveCurrentUser(user: currentUser)
                logManager?
                    .trackEvent(
                        event: Event.saveLocalSuccess(
                            user: currentUser
                        )
                    )
            } catch {
                logManager?
                    .trackEvent(
                        event: Event.saveLocalFail(
                            error: error
                        )
                    )
            }
            
        }
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}

// MARK: - Event
private extension UserManager {
    
    enum Event: LoggableEvent {
        case logInStart(user: UserModel?)
        case logInSuccess(user: UserModel?)
        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel?)
        case remoteListenerFail(error: Error)
        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess
        
        
        var eventName: String {
            switch self {
            case .logInStart: "UserMan_LogIn_Start"
            case .logInSuccess: "UserMan_LogIn_Success"
            case .remoteListenerStart: "UserMan_RemoteListener_Start"
            case .remoteListenerSuccess: "UserMan_RemoteListener_Success"
            case .remoteListenerFail: "UserMan_RemoteListener_Fail"
            case .saveLocalStart: "UserMan_SaveLocal_Start"
            case .saveLocalSuccess: "UserMan_SaveLocal_Success"
            case .saveLocalFail: "UserMan_SaveLocal_Fail"
            case .signOut: "UserMan_SignOut"
            case .deleteAccountStart: "UserMan_DeleteAccount_Start"
            case .deleteAccountSuccess: "UserMan_DeleteAccount_Success"
                
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .logInStart(user: let user), .logInSuccess(user: let user), .remoteListenerSuccess(user: let user), .saveLocalStart(user: let user), .saveLocalSuccess(user: let user):
                return user?.eventParameters
            case .remoteListenerFail(error: let error), .saveLocalFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .remoteListenerFail, .saveLocalFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
