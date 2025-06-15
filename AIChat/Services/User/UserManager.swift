//
//  UserManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 13.06.2025.
//

import Foundation

protocol UserManagerProtocol: Sendable {
    
    @MainActor func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    @MainActor func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
    @MainActor func signOut()
    @MainActor func deleteCurrentUser() async throws
}

@MainActor
@Observable
final class UserManager {
    
    private let remoteService: RemoteUserServiceProtocol
    private let localStorage: LocalUserServiceProtocol
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?
    
    init(services: UserServicesProtocol) {
        self.remoteService = services.remoteService
        self.localStorage = services.localStorage
        self.currentUser = localStorage.getCurrentUser()
    }
}

extension UserManager: UserManagerProtocol {
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        
        try await remoteService.saveUser(user: user)
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
    }
    
    func deleteCurrentUser() async throws {
        let uId = try currentUserId()
        try await remoteService.deleteUser(userId: uId)
        signOut()
    }
}

private extension UserManager {
    
    func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()
        Task {
            do {
                for try await value in remoteService.streamUser(userId: userId) {
                    self.currentUser = value
                    saveCurrentUserLocally()
                    print("Successfully listened to user changes for userId: \(value.userId)")
                }
            } catch {
                print("Error attaching user listener: \(error)")
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
        Task {
            do {
                try localStorage.saveCurrentUser(user: currentUser)
                print("Success saved current user locally")
            } catch {
                print("Error saving current user locally: \(error)")
            }
            
        }
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
