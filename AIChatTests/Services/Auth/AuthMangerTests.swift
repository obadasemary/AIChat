//
//  AuthMangerTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 16.07.2025.
//

import Testing
@testable import AIChat

struct AuthMangerTests {

    @Test("Initialization with Authenticated User")
    func testInitializationWithAuthenticatedUser() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = await MockAuthService(currentUser: mockUser)
        
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        
        let authManager = await AuthManager(
            service: authService,
            logManager: logManager
        )
        
        await #expect(authManager.auth?.uid == mockUser.uid)
    }
    
    @Test("Initialization with Non-Authenticated User")
    func testInitializationWithNonAuthenticatedUser() async throws {
        let authService = await MockAuthService(currentUser: nil)
        
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        
        let authManager = await AuthManager(
            service: authService,
            logManager: logManager
        )
        
        await #expect(authManager.auth == nil)
    }

    @Test("Sign In Anonymously")
    func testSignInAnonymously() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: true)
        let authService = await MockAuthService(currentUser: mockUser)
        let authManager = await AuthManager(service: authService)
        
        let result = try await authManager.signInAnonymously()
        
        #expect(result.user.isAnonymous == true)
        await #expect(authManager.auth?.isAnonymous == true)
    }
    
    @Test("Sign In with Apple")
    func testSignInWithApple() async throws {
        let authService = await MockAuthService()
        let authManager = await AuthManager(service: authService)
        
        let result = try await authManager.signInWithApple()
        
        #expect(result.user.isAnonymous == false)
    }
    
    @Test("Sign In with Google")
    func testSignInWithGooglee() async throws {
        let authService = await MockAuthService()
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let authManager = await AuthManager(
            service: authService,
            logManager: logManager
        )
        
        let result = try await authManager.signInWithGoogle()
        
        #expect(result.user.isAnonymous == false)
        await #expect(authManager.auth?.isAnonymous == false)
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == AuthManager.Event.authListenerStart.eventName
                }
        )
    }
    
    @Test("Sign Out")
    func testSignOut() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = await MockAuthService(currentUser: mockUser)
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let authManager = await AuthManager(
            service: authService,
            logManager: logManager
        )
        
        try await authManager.signOut()
        
//        await #expect(authManager.auth == nil)
        
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == AuthManager.Event.signOutStart.eventName
                }
        )
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == AuthManager.Event.signOutSuccess.eventName
                }
        )
    }
    
    @Test("Delete Account")
    func testDeleteAccount() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = await MockAuthService(currentUser: mockUser)
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let authManager = await AuthManager(
            service: authService,
            logManager: logManager
        )
        
        _ = try await authManager.deleteAccount()
        await #expect(authManager.auth == nil)
        
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == AuthManager.Event.deleteAccountStart.eventName
                }
        )
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == AuthManager.Event.deleteAccountSuccess.eventName
                }
        )
    }
}

