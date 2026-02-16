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
    
    @Test("Link Apple Account")
    func test_whenLinkAppleAccount_thenUserAuthInfoUpdated() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: true)
        let authService = await MockAuthService(currentUser: mockUser)
        let authManager = await AuthManager(service: authService)
        
        let result = try await authManager.linkAppleAccount()
        
        #expect(result.hasAppleLinked == true)
        await #expect(authManager.auth?.hasAppleLinked == true)
    }
    
    @Test("Link Apple Account Tracks Analytics")
    func test_whenLinkAppleAccount_thenAnalyticsTracked() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: true)
        let authService = await MockAuthService(currentUser: mockUser)
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let authManager = await AuthManager(service: authService, logManager: logManager)
        
        _ = try await authManager.linkAppleAccount()
        
        #expect(mockLogService.trackedEvents.contains {
            $0.eventName == "AuthMan_LinkApple_Start"
        })
        #expect(mockLogService.trackedEvents.contains {
            $0.eventName == "AuthMan_LinkApple_Success"
        })
    }

    @Test("Link Google Account")
    func test_whenLinkGoogleAccount_thenUserAuthInfoUpdated() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: true)
        let authService = await MockAuthService(currentUser: mockUser)
        let authManager = await AuthManager(service: authService)
        
        let result = try await authManager.linkGoogleAccount()
        
        #expect(result.hasGoogleLinked == true)
        await #expect(authManager.auth?.hasGoogleLinked == true)
    }

    @Test("Link Account When User Not Found")
    func test_whenLinkAccountWithNoUser_thenThrowsError() async throws {
        let authService = await MockAuthService(currentUser: nil)
        let authManager = await AuthManager(service: authService)
        
        await #expect(throws: MockAuthService.MockAuthError.userNotFound) {
            try await authManager.linkAppleAccount()
        }
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

